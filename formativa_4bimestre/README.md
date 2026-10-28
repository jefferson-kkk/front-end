# Perto - Mapa de Lugares

Aplicativo Flutter desenvolvido para a atividade formativa do 4º bimestre. O app ajuda a descobrir estabelecimentos e pontos de interesse em **São Paulo, Campinas e Jundiaí**, pesquisar por nome ou categoria e salvar lugares próprios no Cloud Firestore.

## Objetivo da atividade

Construir uma aplicação de mapas que combine dados geográficos reais com persistência em nuvem. A atividade reúne interface Flutter, consulta a serviços OpenStreetMap, autenticação Firebase, banco NoSQL e operações de cadastro, consulta, atualização e exclusão.

## O que o aplicativo faz

- Exibe mapa navegável com ruas e bairros reais do OpenStreetMap.
- Permite escolher entre São Paulo, Campinas e Jundiaí e centraliza o mapa na cidade.
- Busca estabelecimentos por texto e restringe os resultados à cidade selecionada.
- Mostra resultados públicos do OpenStreetMap e locais próprios salvos no Firestore.
- Permite abrir os detalhes de um resultado, incluindo categoria, endereço e coordenadas quando disponíveis.
- Permite cadastrar, editar, excluir e favoritar locais próprios no Firestore.
- Guarda nos locais cadastrados nome, categoria, cidade, avaliação, distância, horário, descrição, favorito, latitude e longitude.

## Como foi desenvolvido

1. A interface foi organizada em telas Flutter: o mapa principal, a lista de resultados e os detalhes de um local. Um formulário reutilizável cria e edita os registros próprios.
2. O mapa esquemático inicial foi substituído por `flutter_map`, que carrega os tiles do OpenStreetMap e desenha marcadores nas coordenadas dos lugares.
3. A busca de lugares foi separada do banco de dados do usuário. O serviço consulta Nominatim, serviço de busca do OpenStreetMap, com o termo digitado e limites geográficos da cidade. Assim, a pesquisa de lugares públicos funciona mesmo se o Firestore estiver indisponível.
4. Os locais criados pelo usuário são convertidos pelo modelo `Local` para documentos da coleção `locais`. `LocalService` concentra as operações de Firestore e o fluxo de resultados mescla esses registros com os resultados públicos.
5. O projeto Firebase `perto-mapa` foi ligado às plataformas Android, iOS e Web pelo FlutterFire CLI. A aplicação inicia o Firebase Core e cria uma sessão anônima do Firebase Authentication para que as regras do banco possam exigir autenticação sem solicitar cadastro ao usuário.
6. As regras do Firestore limitam acesso à coleção `locais` a usuários autenticados e validam campos, tipos e faixas de valores antes de aceitar novos documentos ou alterações.

## Tecnologias e serviços

- **Dart e Flutter**: linguagem e framework da aplicação multiplataforma.
- **flutter_map**: mapa interativo, camadas de tiles e marcadores.
- **OpenStreetMap**: dados cartográficos e tiles do mapa.
- **Nominatim**: pesquisa textual de lugares por cidade e região.
- **http**: chamadas HTTP ao serviço Nominatim.
- **latlong2**: representação de latitude e longitude dos marcadores.
- **Firebase Core**: inicialização do Firebase no app.
- **Firebase Authentication**: sessão anônima usada para controlar acesso às regras.
- **Cloud Firestore**: banco de documentos da coleção `locais`.
- **FlutterFire CLI**: geração de `lib/firebase_options.dart` e registro das plataformas.

## Organização do código

```text
lib/
  main.dart                         Inicialização do Firebase e da aplicação
  firebase_options.dart             Configurações geradas pelo FlutterFire
  models/local.dart                 Modelo e conversão de dados do local
  screens/mapa_screen.dart          Mapa, escolha de cidade e marcadores
  screens/resultados_screen.dart    Pesquisa, filtros e lista de locais
  screens/detalhes_screen.dart      Detalhes e favoritos
  services/local_service.dart       Operações no Cloud Firestore
  services/open_street_map_service.dart  Pesquisa Nominatim/OpenStreetMap
  widgets/local_form_dialog.dart    Formulário de cadastro e edição
firestore.rules                     Regras de segurança da coleção locais
firebase.json                       Vínculo FlutterFire e regras do Firestore
test/
  open_street_map_service_test.dart Teste da consulta e conversão de resultados
  widget_test.dart                  Testes do modelo e da tela do mapa

```

## Firebase configurado

- **Projeto Firebase:** `perto-mapa` (nome de exibição: Perto Mapa).
- **Banco:** Cloud Firestore Native, edição Standard.
- **Região:** São Paulo (`southamerica-east1`). A região do banco não pode ser alterada após a criação.
- **Coleção usada:** `locais`.
- **Autenticação:** provedor Anônimo ativado. Cada instalação cria uma sessão anônima para acessar o banco.
- **Regras:** estão em `firestore.rules` e já foram publicadas no projeto.
- **Plataformas registradas:** Android, iOS e Web.

Os locais retornados pelo OpenStreetMap são resultados públicos de busca e **não são copiados automaticamente para o Firestore**. Apenas os locais cadastrados pelo usuário são persistidos na coleção `locais`.

## Executar localmente

Pré-requisitos: Flutter/Dart compatíveis com o SDK do `pubspec.yaml`, conexão com a internet para tiles e busca OpenStreetMap e acesso ao projeto Firebase para usar operações de banco.

```powershell
flutter pub get
flutter run -d chrome
```

Para Android, abra um emulador ou conecte um dispositivo e execute `flutter run`. A configuração Firebase Android está em `android/app/google-services.json`. iOS e Web usam as opções geradas em `lib/firebase_options.dart`.

## Verificações

```powershell
flutter analyze
flutter test
flutter build web
```

A configuração do Firebase e o app foram verificados; o projeto compila para Web e os testes automatizados passam.

## Observações sobre serviços públicos

A busca de lugares depende de conexão com a internet e dos serviços públicos do OpenStreetMap. A base é colaborativa: nem todo estabelecimento está mapeado, e nomes, categorias ou endereços podem estar ausentes ou desatualizados. O Nominatim limita a frequência de consultas; o app espaça chamadas para respeitar esse limite. Para uso público em grande escala, avalie contratar ou hospedar um serviço de geocodificação adequado e respeite as políticas de atribuição e uso dos tiles do OpenStreetMap.

O mapa mostra localizações e não oferece, nesta versão, navegação curva a curva, localização GPS atual do usuário, avaliações verificadas ou sincronização offline.
