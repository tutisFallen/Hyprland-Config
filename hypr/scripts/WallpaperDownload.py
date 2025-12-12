#!/usr/bin/env python3
import os
import time
import requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import re
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

BASE_URL = "https://alphacoders.com/anime-wallpapers"
OUTDIR = "Wallpaprs_tutis"
os.makedirs(OUTDIR, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
}

DELAY = 1
SCROLL_PAUSE = 3
MAX_WORKERS = 5  # Número de downloads simultâneos

# Lock para sincronizar o contador
counter_lock = Lock()
download_counter = 0

def get_page_links_with_scroll(driver, page_num):
    """Faz scroll na página atual e coleta todos os links"""
    links = set()
    last_height = driver.execute_script("return document.body.scrollHeight")
    no_change_count = 0
    scrolls = 0
    max_scrolls = 15
    
    print(f"  Fazendo scroll na página {page_num}...")
    
    while scrolls < max_scrolls:
        soup = BeautifulSoup(driver.page_source, "html.parser")
        pattern = re.compile(r'/big\.php\?i=\d+')
        
        for a in soup.find_all("a", href=True):
            href = a['href']
            if pattern.search(href):
                if href.startswith("http"):
                    links.add(href)
                elif href.startswith("/"):
                    links.add("https://wall.alphacoders.com" + href)
                else:
                    links.add("https://wall.alphacoders.com/" + href)
        
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(SCROLL_PAUSE)
        
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            no_change_count += 1
            if no_change_count >= 2:
                break
        else:
            no_change_count = 0
        
        last_height = new_height
        scrolls += 1
    
    print(f"  ✓ {len(links)} links coletados na página {page_num}")
    return list(links)

def navigate_pages(start_page, end_page):
    """Navega pelas páginas e coleta todos os links"""
    print("Iniciando navegador...")
    
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument(f"user-agent={HEADERS['User-Agent']}")
    
    driver = webdriver.Chrome(options=chrome_options)
    all_links = set()
    
    try:
        for page_num in range(start_page, end_page + 1):
            if page_num == 1:
                url = BASE_URL
            else:
                url = f"{BASE_URL}?page={page_num}"
            
            print(f"\n[Página {page_num}] Carregando {url}")
            driver.get(url)
            time.sleep(2)
            
            links = get_page_links_with_scroll(driver, page_num)
            all_links.update(links)
        
        print(f"\n{'='*50}")
        print(f"Total de links únicos coletados: {len(all_links)}")
        print(f"{'='*50}\n")
        
        return list(all_links)
        
    finally:
        driver.quit()

def get_image_from_page(page_url):
    """Acessa a página individual e extrai a URL da imagem real"""
    try:
        r = requests.get(page_url, headers=HEADERS, timeout=15)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, "html.parser")
        
        img = soup.find("img", id="main-content")
        if img and img.get("src"):
            src = img['src']
            pattern = re.compile(r'\d+\.(jpg|jpeg|png)$', re.IGNORECASE)
            if pattern.search(src):
                if src.startswith("http"):
                    return src
                else:
                    return "https:" + src if src.startswith("//") else "https://alphacoders.com" + src
        return None
    except Exception as e:
        return None

def download_image(url):
    """Baixa uma imagem e retorna True se sucesso"""
    global download_counter
    
    try:
        ext = url.split('.')[-1].split('?')[0].lower()
        if ext not in ['jpg', 'jpeg', 'png']:
            ext = 'jpg'
        
        # Incrementa o contador de forma thread-safe
        with counter_lock:
            download_counter += 1
            count = download_counter
        
        filename = f"img_{count:04d}.{ext}"
        path = os.path.join(OUTDIR, filename)
        
        r = requests.get(url, headers=HEADERS, stream=True, timeout=15)
        if r.status_code == 200:
            with open(path, "wb") as f:
                for chunk in r.iter_content(1024 * 16):
                    f.write(chunk)
            print(f"✓ [{count}] Baixado: {filename}")
            return True
        else:
            print(f"✗ [{count}] Falhou ({r.status_code})")
            return False
    except Exception as e:
        print(f"✗ Erro ao baixar: {e}")
        return False

def process_and_download(page_link, index, total):
    """Processa uma página e baixa a imagem"""
    print(f"[{index}/{total}] Processando: {page_link}")
    
    img_url = get_image_from_page(page_link)
    
    if img_url:
        return download_image(img_url)
    else:
        print(f"✗ [{index}] Imagem não encontrada")
        return False

def main():
    print(f"\n{'='*50}")
    print("SCRAPER DE WALLPAPERS - ALPHACODERS")
    print(f"{'='*50}\n")
    
    while True:
        try:
            start_page = int(input("Página inicial (ex: 1): "))
            end_page = int(input("Página final (ex: 10): "))
            
            if start_page < 1 or end_page < 1:
                print("❌ As páginas devem ser maiores que 0!\n")
                continue
            
            if start_page > end_page:
                print("❌ A página inicial deve ser menor ou igual à final!\n")
                continue
            
            break
        except ValueError:
            print("❌ Digite apenas números!\n")
    
    print(f"\n✓ Processando páginas {start_page} a {end_page}")
    print(f"  Total de páginas: {end_page - start_page + 1}")
    print(f"  Downloads simultâneos: {MAX_WORKERS}\n")
    
    page_links = navigate_pages(start_page, end_page)
    
    if not page_links:
        print("✗ Nenhum link encontrado.")
        return
    
    print(f"\nIniciando downloads paralelos ({MAX_WORKERS} threads)...\n")
    
    downloaded = 0
    total = len(page_links)
    
    # Usa ThreadPoolExecutor para downloads paralelos
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        # Submete todas as tarefas
        futures = {
            executor.submit(process_and_download, link, i, total): link 
            for i, link in enumerate(page_links, 1)
        }
        
        # Processa conforme completam
        for future in as_completed(futures):
            if future.result():
                downloaded += 1
    
    print(f"\n{'='*50}")
    print(f"✓ CONCLUÍDO!")
    print(f"  {downloaded}/{total} imagens baixadas")
    print(f"  Pasta: {OUTDIR}/")
    print(f"{'='*50}\n")

if __name__ == "__main__":
    main()