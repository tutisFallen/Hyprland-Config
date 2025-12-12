![alt text](image.png)


## 🚀 DarkMatterShell + Hyprland Auto Installer

Um instalador automático e robusto para configurar um ambiente de desktop completo, minimalista e altamente personalizável com **Hyprland**, **DankMaterialShell**, o tema visual **GNOME macOS Tahoe**, pacotes essenciais e ajustes padrões no Arch Linux e derivados.

---

### ✨ O que este script faz por você

Este instalador transforma uma instalação base do Arch Linux em um ambiente de trabalho esteticamente agradável e funcional, configurando automaticamente:

* **Window Manager:** Hyprland (Tiling Dinâmico Moderno).
* **Shell Gráfica:** DankMaterialShell (Um *shell* projetado para produtividade e estética).
* **Tematização:** GNOME macOS Tahoe (Aparência limpa e familiar, inspirada no macOS).
* **Pacotes Essenciais:** Um conjunto curado de aplicações e utilitários de sistema.
* **Gerenciamento de Pacotes:** Instalação e configuração de um helper AUR (como `yay`) se necessário.

### 📋 Pré-requisitos

Para garantir uma instalação suave, seu sistema deve atender aos seguintes critérios:

* **Sistema Operacional:** Arch Linux ou qualquer distribuição baseada em `pacman` (e.g., Manjaro, EndeavourOS, ArcoLinux).
* **Dependências Iniciais:** `git` e o grupo `base-devel`.
* **Conexão:** Uma conexão de internet ativa e estável.

> O script é projetado para ser autônomo: ele fará o download de todas as outras dependências, incluindo o `yay` (caso você não possua um helper AUR).

---

### 📥 Começando (Instalação Rápida)

Siga estas instruções para clonar e executar o instalador na sua máquina.

1.  **Clone o Repositório:**
    ```bash
    git clone [https://github.com/tutisFallen/Hyprland-Config.git](https://github.com/tutisFallen/Hyprland-Config.git)
    ```

2.  **Acesse a Pasta:**
    ```bash
    cd Hyprland-Config
    ```

3.  **Dê Permissão de Execução e Execute:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

> A execução requer `sudo` para instalar pacotes. Você será solicitado a fornecer sua senha. **Aguarde o processo terminar**; ele reiniciará automaticamente o sistema ao final.

---

### ⚙️ Detalhes da Instalação (Passos do Script)

O script automatiza e isola as seguintes etapas de configuração:

1.  **Instalação de Helper AUR:** Verifica a existência de `yay` ou `paru` e instala `yay` se necessário.
2.  **Instalação de Pacotes:** Utiliza `pacman` e o helper AUR para instalar todo o ambiente.
3.  **Configuração de Temas e WM:** Aplica o tema **GNOME macOS Tahoe** e move as configurações (`hypr/` e `DankMaterialShell/`) para `~/.config/`.
4.  **Tratamento de Erros e Relatório:** Cada pacote é instalado **individualmente** (falhas não interrompem o script). Ao final, um **relatório completo** lista os pacotes que não puderam ser instalados.
5.  **Conclusão:** O sistema é **reiniciado automaticamente** para que você possa iniciar na nova sessão Hyprland.

---

### 🛡️ Testes e Robustez

O `install.sh` inclui mecanismos de validação para garantir a máxima confiabilidade e facilidade de depuração.

| Categoria | Descrição |
| :--- | :--- |
| **Checagens Internas** | Teste de conexão com `sudo`, teste de existência de helper AUR, disponibilidade de pacotes `pacman`. |
| **Validação Ponto a Ponto** | Instalação isolada de cada pacote `pacman` e `AUR`. Falhas são registradas, mas o processo continua. |
| **Qualidade do Código** | Estrutura de código validada para sintaxe `bash` (uso de `set -e`), cores ANSI padronizadas e tratamento de erros por pacote. |

---

### 📦 Implantação e Contribuição

Para implantar em outras máquinas ou contribuir:

1.  **Suba seu repositório:** Certifique-se de que o projeto esteja no seu GitHub.
2.  **Máquina Alvo:**
    ```bash
    git clone [https://github.com/tutisFallen/Hyprland-Config.git](https://github.com/tutisFallen/Hyprland-Config.git)
    cd Hyprland-Config
    ./install.sh
    ```

#### 🛠️ Construído com

* **Bash:** Linguagem principal do instalador.
* **pacman:** Gerenciador de pacotes principal do Arch.
* **yay/paru:** Helpers do AUR para pacotes da comunidade.
* **Git:** Versionamento e clonagem de repositórios.
* **Hyprland:** Window Manager Tiling dinâmico.
* **DankMaterialShell:** Shell gráfica integrada @DankMaterialShell.
* **GNOME macOS Tahoe Theme:** Tematização adicional @kayozxo.

### 🤝 Contribuições

Contribuições são sempre bem-vindas! Se você tiver sugestões, *bug reports* ou queira melhorar o código, sinta-se à vontade para abrir uma *Issue* ou um *Pull Request* no repositório.
