# ConfirmaID

ConfirmaID é um aplicativo desenvolvido em Flutter que utiliza assinaturas digitais e funções de hash para verificar a identidade de usuários em interações digitais. Foi projetado como uma solução prática para mitigar fraudes de identidade, com um fluxo de cadastro, autenticação e consulta de informações que assegura privacidade, segurança e conformidade com a legislação de proteção de dados.

Este projeto foi desenvolvido durante a Hackathon da SECCOM 2024 no decorrer de 5 dias, na qual conquistou o **1º lugar**. O tema do evento foi "Segurança".
---

## 🔍 Funcionamento

### Fluxo das Telas

1. **Tutorial**: Na primeira execução, o usuário é apresentado a telas explicativas sobre o uso do aplicativo.
2. **Tela Inicial**: Apresenta as opções de login, cadastro ou busca de informações.
3. **Cadastro**: O usuário preenche nome, CPF e outras informações básicas. Um e-mail é enviado com um documento PDF para assinatura digital.
4. **Autenticação**: O documento assinado digitalmente pelo Gov.br é enviado de volta para validação. O sistema verifica o nome e o CPF no certificado da assinatura digital.
5. **Gerenciamento de Dados**: Após autenticado, o usuário pode adicionar e gerenciar informações como e-mail, telefone e outros contatos.
6. **Busca e Verificação**: Qualquer usuário pode consultar informações cadastradas, verificando se os dados fornecidos correspondem aos armazenados.

---

### Principais Funcionalidades

- **Cadastro Seguro**: Requer assinatura digital pelo Gov.br para validar a identidade do usuário.
- **Verificação de Dados**: Permite consultar informações como número de telefone ou e-mail e verificar se correspondem ao registro.
- **Privacidade por Design**: As informações sensíveis são armazenadas como hashes, protegendo contra vazamentos.
- **Interface Modular**: Telas intuitivas organizadas em fluxos simples e autoexplicativos.

---

### Sistema de Autenticação

O sistema utiliza assinaturas digitais emitidas pelo Gov.br, integrando um modelo de confiança pública reconhecido. Durante o processo:

1. O usuário recebe um PDF com uma declaração específica para o cadastro.
2. A assinatura digital no documento é validada por meio da API ICP-Brasil.
3. Os dados do certificado (nome e CPF) são comparados com as informações fornecidas no cadastro.
4. Apenas após a validação, o usuário tem acesso às funcionalidades completas do sistema.

---

## 🛠️ Tecnologias Utilizadas

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL)
- **APIs externas**:
  - [Verificador de Conformidade ICP-Brasil](https://pbad.labsec.ufsc.br/verifier-hom/docs/api) para validação de assinaturas digitais.
  - [NotificationAPI](https://www.notificationapi.com/) para envio de documentos via e-mail.
- **Outros**:
  - Armazenamento local com `shared_preferences`.
  - Ferramentas de design: Adobe XD.

---

## 📂 Estrutura do Projeto

O código está organizado de forma modular, com a seguinte estrutura principal:

```
lib/
├── features/          # Funcionalidades principais
├── components/shared/ # Componentes reutilizáveis
├── utils/             # Utilitários e funções auxiliares
├── main.dart          # Ponto de entrada do aplicativo
```

---

## 🔒 Segurança e Privacidade

- **Hashing**: Dados sensíveis são armazenados utilizando SHA-256 com salting, dificultando correlações entre bases de dados comprometidas.
- **Validação de Identidade**: Assinaturas digitais garantem que os dados fornecidos pertencem ao usuário correto.
- **LGPD**: Todos os dados coletados são tratados em conformidade com a legislação brasileira, com termos de uso claros e explícitos.

---

## 📚 Documentação

Para mais detalhes sobre o desenvolvimento e arquitetura, consulte o [Relatório do Projeto](https://github.com/Soul-Legend/HackatonFlutter2024/blob/main/Relatorio%20Hackaton.pdf).

---

## 👥 Equipe

- **Pedro Henrique Taglialenha**
- **Vitor Praxedes Calegari**
- **Rita Louro Barbosa**

## 🏆 Premiação

ConfirmaID foi o vencedor da **Hackathon SECCOM 2024**.

---

##  Próximos Passos

- Implementar autenticação de atributos para validação de canais de comunicação.
- Adicionar notificações periódicas para atualização de dados.
- Expandir o suporte para novos modelos de autenticação digital.

Agradecemos o interesse em nosso projeto e estamos abertos a colaborações e sugestões! 🎉
