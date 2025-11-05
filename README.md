# 🎲 Aplicativo RPG-Dicell (Entrega - Parte 2)

Este repositório contém o código-fonte do projeto prático da disciplina de Programação de Dispositivos Móveis do curso de ADS da UTFPR.

## 📝 Descrição do Projeto

O objetivo do projeto é desenvolver um aplicativo móvel em Flutter para auxiliar na organização e gerenciamento de campanhas de RPG de mesa. A aplicação permite que usuários se cadastrem, criem campanhas, gerenciem sessões, armazenem fichas de personagem e interajam em tempo real.

---

## 🚀 Resumo da Entrega (Parte 2)

O foco principal desta segunda entrega foi a **migração completa do backend**. O protótipo da Parte 1, que utilizava dados em memória e controllers "falsos", foi substituído por uma arquitetura robusta, persistente e online, utilizando os serviços de nuvem do Google Firebase.

As principais mudanças foram:

1.  **Sistema de Autenticação Real:**
    * O `AuthController` foi totalmente reescrito para se integrar ao **Firebase Authentication**.
    * O cadastro, login e logout agora são processos seguros e persistentes, gerenciados pelo Firebase.

2.  **Banco de Dados Online (Cloud Firestore):**
    * Todas as listas em memória (`_campaigns`, `_sheets`, `_sessions`) foram substituídas por coleções no **Cloud Firestore**.
    * O `CampaignController` e o `CharacterController` agora realizam operações de CRUD (Create, Read, Update, Delete) diretamente no banco de dados na nuvem.
    * Todos os dados (usuários, fichas, campanhas) agora são persistentes e não são perdidos ao fechar o app.

3.  **Atualizações em Tempo Real:**
    * As telas de listagem (Biblioteca de Fichas, Lista de Campanhas e Detalhes da Campanha) foram refatoradas para usar `StreamBuilder`s.
    * Isso permite que o aplicativo reaja a mudanças no banco de dados em tempo real. Ex: Quando um Mestre agenda uma sessão, ela aparece automaticamente na tela de todos os jogadores logados, sem a necessidade de recarregar.

---

## 💻 Tecnologias Utilizadas

* **Flutter & Dart:** Framework e linguagem principal para o desenvolvimento da UI.
* **Firebase Authentication:** Para gerenciamento seguro de cadastro, login e sessões de usuário.
* **Cloud Firestore:** Banco de dados NoSQL online para persistência de campanhas, fichas, sessões e dados de usuários.
* **Provider:** Para injeção de dependência e gerenciamento de estado (disponibilizando os controllers para a árvore de widgets).
* **Arquitetura:** MVC (Model-View-Controller) onde os Controllers atuam como `ChangeNotifier`s, conectando as Views ao backend do Firebase.
* **Pacotes Adicionais:** `intl` (para formatação de datas).

---

## 🚀 Como Executar o Projeto

**Importante:** Este projeto depende de uma conexão ativa com o Firebase (Authentication e Firestore). O arquivo de configuração (`lib/firebase_options.dart`) está incluído no repositório.

1.  Clone o repositório:
    ```bash
    git clone [https://github.com/luhrsouza/aplicativo-rpg.git](https://github.com/luhrsouza/aplicativo-rpg.git)
    ```
2.  Navegue até a pasta do projeto:
    ```bash
    cd aplicativo-rpg
    ```
3.  Instale as dependências:
    ```bash
    flutter pub get
    ```
4.  Execute o aplicativo:
    ```bash
    flutter run
    ```

---

## 👥 Equipe e Contribuições
 Integrante | Atividades Desenvolvidas | RA
| Luciana Ramos de Souza| Todo o projeto | a2566150

