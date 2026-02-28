# Eras Pós-Cyberpunk (Opção A)

## Direção escolhida

**Opção A: Linha do tempo quebrada**

Depois da era Cyberpunk, as fissuras temporais ficam instáveis e misturam passado, futuro e realidades paralelas.  
Com isso, eras historicamente distantes podem coexistir de forma coerente no universo do jogo.

### Por que essa opção funciona

- Liberdade criativa máxima para tema, arte e mecânicas.
- Justifica Roma/Grécia e Egito tecnológicos sem parecer incoerente.
- Mantém sensação de escalada de caos até o grande clímax final.

## Ordem sugerida de progressão

1. Cyberpunk (ponto de ruptura)
2. Singularidade
3. Neo-Hélade (Roma/Grécia Tecnomítica)
4. Egito Antigo Tecnológico
5. End of the World

## Eras atuais do jogo (estado do código)

Atualmente, o enum `WorkerEra` contém as seguintes eras:

1. Victorian Era (`victorian`)
2. Roaring 20s (`roaring_20s`)
3. Atomic Age (`atomic_age`)
4. Cyberpunk 80s (`cyberpunk_80s`)
5. Neo-Tokyo (`neo_tokyo`)
6. Post-Singularity (`post_singularity`)
7. Ancient Rome (`ancient_rome`)
8. Far Future (`far_future`)

### Descrição das eras atuais (mesmo padrão)

## Victorian Era

Estética industrial/steampunk de origem, com fábricas mecânicas, vapor e engrenagens como base da progressão temporal.

### Identidade visual

- Ferro, cobre, latão e fumaça.
- Máquinas analógicas com pistões, válvulas e relógios industriais.
- Silhuetas vitorianas com detalhes mecânicos.

### Fantasia dos workers

- Operários de forja temporal
- Engenheiros de caldeira
- Mestres relojoeiros

## Roaring 20s

Era de art déco, crescimento urbano acelerado e glamour mecânico, onde elegância e produtividade andam juntas.

### Identidade visual

- Prédios art déco, letreiros luminosos e jazz industrial.
- Preto/dourado com brilho metálico e geometrias simétricas.
- Máquinas refinadas, rápidas e mais eficientes.

### Fantasia dos workers

- Magnatas industriais
- Inventores de salão
- Operadores de linha de luxo

## Atomic Age

Energia nuclear, otimismo científico e risco tecnológico: poder massivo com perigo constante de instabilidade.

### Identidade visual

- Reatores, símbolos atômicos e instrumentação científica.
- Paleta com verdes radioativos, amarelos de alerta e aço escovado.
- Ambientes de laboratório e usina de alta potência.

### Fantasia dos workers

- Cientistas nucleares
- Técnicos de contenção
- Operadores de reator

## Cyberpunk 80s

Megacorporações, neon e alta automação dominam a economia temporal em um cenário urbano denso e hiperconectado.

### Identidade visual

- Chuva neon, hologramas, cabos expostos e painéis digitais.
- Roxo, ciano, magenta e contraste noturno intenso.
- Infraestrutura corporativa e distritos industriais verticalizados.

### Fantasia dos workers

- Mercenários de dados
- Hackers de produção
- Operadores de drones industriais

## Compatibilização: eras atuais x proposta nova

- **Post-Singularity** já cobre muito da fantasia de **Singularidade**.
- **Ancient Rome** pode ser evoluída para a proposta **Neo-Hélade (Roma/Grécia Tecnomítica)**.
- **Far Future** pode virar ponte para **End of the World** ou ser mantida como etapa anterior ao colapso final.
- **Egito Antigo Tecnológico** é conteúdo novo (ainda não representado diretamente no enum atual).

## Descrição das Eras

## 1) Singularidade

Um futuro tão distante que humanos e IA viraram uma espécie híbrida.  
Cidades vivas, consciência em rede e corpos biomecânicos.

### Identidade visual

- Arquitetura orgânica + circuitos.
- Tons frios e brilhantes, com efeitos holográficos.
- Worker designs misturando carne sintética e metal inteligente.

### Fantasia dos workers

- Monges de dados
- Engenheiros neurais
- Generais quânticos

## 2) Neo-Hélade (Roma/Grécia Tecnomítica)

Impérios de mármore, ouro e neon.  
Espartanos com exotrajes, atenienses com academias de IA e “deuses” tratados como superinteligências.

### Identidade visual

- Colunas clássicas com runas digitais.
- Armaduras antigas com núcleo energético.
- Monumentos e arenas com tecnologia divina.

### Fantasia dos workers

- Hoplitas cibernéticos
- Estrategistas atenienses de IA
- Oráculos de dados

## 3) Egito Antigo Tecnológico

Pirâmides-reator, obeliscos de energia solar e hieróglifos que funcionam como código-fonte.  
Faraós-cibernéticos governam com sacerdotes-engenheiros.

### Identidade visual

- Ouro, arenito e neon azul.
- Símbolos egípcios com interfaces luminosas.
- Máquinas ancestrais despertadas por energia temporal.

### Fantasia dos workers

- Guardas Anúbis mecanizados
- Sacerdotes de circuito solar
- Arquitetos de pirâmides quânticas

## 4) End of the World (Terra Destruída)

A guerra final entre humanos e IA devastou o planeta.  
Restam megarruínas, céu tóxico e campos de batalha autônomos.

### Identidade visual

- Sucata, fumaça, fogo e tempestades eletromagnéticas.
- Estruturas quebradas e zonas de conflito.
- Contraste entre resistência humana e precisão fria das IAs.

### Fantasia dos workers

- Comandantes da resistência
- Sucateiros de combate
- Unidades IA renegadas

## Nota de narrativa

A progressão dessas eras deve reforçar a ideia de colapso temporal crescente:  
do futuro pós-humano (Singularidade), passando por civilizações reescritas pela tecnologia (Neo-Hélade e Egito Tecnológico), até o colapso total (End of the World).

---

# FEATURE: Era Singularity (Plano de Implementacao)

Owner: Gameplay + Balance + UI + Content  
Branch sugerida: `feature/era-singularity`  
Status: active  
Ultima atualizacao: 2026-02-27

## Regras de execucao

- Implementar uma story por vez.
- Nao refatorar modulos fora do escopo da story atual.
- Toda story so pode virar `done` com criterios de aceite validados.
- Atualizar o `status:` desta planilha imediatamente apos concluir cada story.
- Enquanto os assets finais nao existirem, usar placeholders white-label (icones e backgrounds).
- Toda alteracao de balanceamento deve registrar numeros `antes x depois`.

## Escopo do plano

- Entregar uma era jogavel de Singularidade (pos-Cyberpunk) com:
- novos techs
- nova expedicao
- nova chamber
- novos workers
- placeholders white-label para arte
- estudo + implementacao de balanceamento seguindo padroes atuais do app

## Proposta inicial de conteudo (baseline)

### Chamber (Singularity)

- Id proposta: `quantum_spire`
- Nome: `Quantum Spire`
- Fantasia: torre neural que sincroniza humanos e IA.
- Target inicial: performance acima de `rift_generator`, sem quebrar progressao.

### Workers (Singularity)

- Common: `Neural Drifter`
- Rare: `Synapse Mechanic`
- Epic: `Cortex Strategist`
- Legendary: `Post-Human Architect`
- Paradox: `Event Horizon Mind`

### Techs (Singularity)

- `neural_mesh` (efficiency)
- `probability_compiler` (timeWarp)
- `nanoforge_cells` (costReduction)
- `swarm_autonomy` (automation)
- `quantum_hibernation` (offline)
- `exo_mind_uplink` (eraUnlock/capstone)

### Expedicao (Singularity)

- Slot id proposto: `singularity_deep_dive`
- Nome: `Convergence Breach`
- Headline: `Reconstrua memoria quantica em zonas de consciencia distribuida.`
- Risco default sugerido: `volatile`

---

# STORIES

## STORY-0: Bootstrap do plano e alinhamento com codigo atual
status: done

Descricao:
Mapear os pontos atuais de era/tech/expedition/chamber/workers para criar um plano executavel.

Aceite:
- Referencias de codigo confirmadas para: `WorkerEra`, `GameConstants.eraOrder`, `TechData`, `ExpeditionSlot.catalog`, `StationType`, `WorkerNameRegistry`.
- Plano estruturado em stories com `status: todo/done`.

Done when:
- Documento salvo com stories e criterios de aceite.

---

## STORY-1: Definir estrategia canonica de ID/ordem da era Singularidade
status: done

Descricao:
Fechar decisao tecnica sobre como Singularidade entra na progressao sem quebrar saves existentes.

Aceite:
- Escolha documentada entre:
  1) reaproveitar `post_singularity` como era Singularity principal (recomendado para compatibilidade), ou
  2) criar novo id `singularity` com migracao de save.
- Ordem final em `GameConstants.eraOrder` documentada e coerente com UX.
- Estrategia de migracao/backward compatibility definida.

Done when:
- Decisao aprovada e registrada neste arquivo.

Decisao aplicada (2026-02-27):
- Opcao escolhida: **reaproveitar `post_singularity` como ID canonico da era Singularity**.
- Motivo: preservar compatibilidade de save e evitar migracao destrutiva nesta fase.
- UX/narrativa: o nome exposto ao jogador passa a ser **Singularity/Singularidade**.
- Compatibilidade: saves antigos continuam validos porque o ID persistido nao muda.

---

## STORY-2: Integrar era no core de progressao
status: done

Descricao:
Aplicar a definicao da Story-1 nas constantes centrais de progressao/economia.

Arquivos alvo:
- `lib/domain/entities/enums.dart`
- `lib/core/constants/game_constants.dart`
- `lib/presentation/utils/localization_extensions.dart`

Aceite:
- Multiplicador, hire cost e ordem de era coerentes.
- Threshold de unlock calibrado para curva pos-Cyberpunk.
- Nenhum crash em carregamento de save antigo.

Done when:
- Build inicia com save novo e save legado sem erro.

Implementado (2026-02-27):
- `WorkerEra.postSingularity` manteve ID `post_singularity` e passou a exibir nome canonico `Singularity`.
- `GameConstants.eraUnlockThresholds['post_singularity']` ajustado de `10Qa` para `6Qa` para reduzir salto pos-Cyberpunk.
- `localization_extensions` atualizado para expor `Singularity`/`Singularidade` na camada de UI sem alterar o ID tecnico.

---

## STORY-3: Criar chamber da Singularidade
status: done

Descricao:
Adicionar uma chamber dedicada da era Singularidade e plugar no fluxo single-chamber.

Arquivos alvo:
- `lib/domain/entities/enums.dart` (novo `StationType`)
- `lib/domain/entities/station.dart` (bonus, custos, paradoxRate)
- `lib/domain/entities/game_state.dart` (`_stationTypeForEra`)
- `lib/presentation/utils/localization_extensions.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_pt.arb`

Aceite:
- Era Singularidade recebe chamber propria ao avancar era.
- `upgradeSingleChamberToEra` aponta para novo tipo corretamente.
- Nome aparece localizado em PT/EN.

Done when:
- Teste manual confirma troca de era + chamber sem perda de workers validos.

Implementado (2026-02-27):
- Nova chamber adicionada em `StationType`: `quantum_spire` (era `post_singularity`).
- Economia da chamber configurada em `station.dart`:
  - bonus de producao acima de `rift_generator`
  - custo base dedicado
  - taxa de paradoxo dedicada
- Fluxo single-chamber pluga automaticamente via `_stationTypeForEra` (agora encontra era com tipo proprio).
- Nome localizado na camada de UI: `Quantum Spire` / `Torre Quantica`.

---

## STORY-4: Criar workers da Singularidade
status: done

Descricao:
Adicionar nomes de workers por raridade e garantir renderizacao de icones white-label.

Arquivos alvo:
- `lib/domain/entities/worker_name_registry.dart`
- `lib/core/utils/worker_icon_helper.dart` (se necessario)
- `assets/images/icons/` (placeholders)

Aceite:
- `WorkerNameRegistry` contem 5 raridades da era.
- Icons placeholders existem para `commum/rare/epic/legendary/paradox`.
- Nenhum erro de asset missing ao abrir telas com workers da era.

Done when:
- Gacha/hire da era mostra nome e icone corretamente.

Implementado (2026-02-27):
- `WorkerNameRegistry` da era `post_singularity` atualizado para os novos nomes:
  - Common: `Neural Drifter`
  - Rare: `Synapse Mechanic`
  - Epic: `Cortex Strategist`
  - Legendary: `Post-Human Architect`
  - Paradox: `Event Horizon Mind`
- `WorkerIconHelper` ajustado para mapear `post_singularity` -> prefixo `singularity`,
  compatibilizando os placeholders:
  - `singularity-icon-commum.png`
  - `singularity-icon-rare.png`
  - `singularity-icon-epic.png`
  - `singularity-icon-legendary.png`
  - `singularity-icon-paradox.png`

---

## STORY-5: Criar techs da Singularidade
status: done

Descricao:
Expandir `TechData.initialTechs` com o pacote da era Singularidade e integrar efeitos nos calculos.

Arquivos alvo:
- `lib/core/constants/tech_data.dart`
- `lib/domain/entities/tech_upgrade.dart` (somente se tipo novo for necessario)
- `lib/presentation/ui/pages/tech_screen.dart` (icone/nome se preciso)

Aceite:
- Minimo 5 techs + 1 capstone adicionados para era Singularidade.
- Efeitos entram corretamente em:
  - `calculateEfficiencyMultiplier`
  - `calculateTimeWarpMultiplier`
  - `calculateCostReductionMultiplier`
  - `calculateOfflineEfficiencyMultiplier`
  - `calculateAutomationLevel`
- Custos e `maxLevel` seguem escala de late-game atual.

Done when:
- Upgrade de tech altera producao/automacao/offline conforme esperado.

Implementado (2026-02-27):
- Pacote de techs da era `post_singularity` adicionado em `TechData.initialTechs`:
  - `neural_mesh` (efficiency)
  - `probability_compiler` (timeWarp)
  - `nanoforge_cells` (costReduction)
  - `swarm_autonomy` (automation)
  - `quantum_hibernation` (offline)
  - `exo_mind_uplink` (capstone eraUnlock)
- Formulas integradas em:
  - `calculateEfficiencyMultiplier`
  - `calculateTimeWarpMultiplier`
  - `calculateCostReductionMultiplier`
  - `calculateOfflineEfficiencyMultiplier`
  - `calculateAutomationLevel`
- `TechUpgrade.bonusDescription` atualizado para refletir escalas corretas dos novos IDs.
- `tech_screen` recebeu mapeamento de icones para as novas techs.

---

## STORY-6: Criar expedicao da Singularidade
status: done

Descricao:
Adicionar/ajustar slot de expedicao especifico da era Singularidade.

Arquivos alvo:
- `lib/domain/entities/expedition.dart`
- `lib/domain/usecases/start_expedition_usecase.dart`
- `lib/domain/usecases/resolve_expeditions_usecase.dart` (somente se tuning extra)
- `lib/l10n/app_en.arb`
- `lib/l10n/app_pt.arb`

Aceite:
- Slot da era aparece quando era correspondente desbloqueada.
- `requiredWorkers`, `duration` e `defaultRisk` coerentes com fase late-game.
- Reward preview e resolve final nao quebram economia.

Done when:
- Fluxo iniciar -> resolver -> coletar expedicao funciona sem regressao.

Implementado (2026-02-27):
- Slot de expedicao da era `post_singularity` recebeu identidade Singularity:
  - `name`: `Convergence Breach`
  - `headline`: nova descricao de reconstrucao de memoria quantica
  - `layoutPreset`: `singularity_whitelabel`
- `slotId` foi mantido como `void_cloud_harvest` para compatibilidade com saves.

---

## STORY-7: White-label visual (background + iconografia da era)
status: done

Descricao:
Entrar com assets temporarios neutros ate chegada da arte final.

Arquivos alvo:
- `assets/images/backgrounds/era_singularity_whitelabel.png`
- `lib/core/constants/game_assets.dart`
- `lib/presentation/ui/templates/era_background.dart`
- `lib/core/theme/era_theme.dart`

Aceite:
- Background da era carrega sem erro.
- Tema da era tem paleta e animacao consistentes (mesmo sem arte final).
- Placeholders sao facilmente substituiveis (nomes estaveis de arquivo).

Done when:
- Era renderiza com identidade minima e sem quebrar UX.

Implementado (2026-02-27):
- Background white-label de Singularity integrado via:
  - `GameAssets.eraSingularityWhitelabel`
  - `EraBackground` para `post_singularity`
  - `EraUnlockDialog` para preview da era
- Tema da era atualizado para nomenclatura de UX:
  - `displayName`: `SINGULARITY (2400)`
- Placeholders de iconografia ja conectados via `WorkerIconHelper` (`prefix: singularity`).

---

## STORY-8: Estudo e implementacao de balanceamento
status: done

Descricao:
Executar estudo numerico e tuning iterativo para garantir progressao justa, sem spike abrupto.

Metodo:
- Capturar baseline atual (Cyberpunk -> era seguinte): CE/s, custo de hires, custo de upgrades, tempo medio para unlock.
- Simular 3 perfis: casual, medio, hardcore.
- Ajustar em ciclos curtos: custo de tech, multiplicadores, rewards de expedicao, bonus da chamber.

Aceite:
- Tempo medio para completar techs da era dentro da janela alvo definida.
- Expedicao da era cobre custo de oportunidade sem quebrar curva.
- Sem "dead zone" de progressao (jogador sempre tem proximo objetivo claro).
- Registro `antes x depois` anexado no PR/commit notes.

Done when:
- Numeros finais aprovados e documentados.

Implementado (2026-02-27):
- Estudo numerico realizado comparando o custo total para fechar a arvore da era `cyberpunk_80s` versus `post_singularity`.
- Baseline antes do tuning (primeira versao da era Singularity):
  - Custo total techs Singularity: `2,295,816,880,000,000,000` CE
  - Custo total techs Cyberpunk 80s: `9,325,322,796,292,657` CE
  - Razao Singularity/Cyberpunk: `246.19x`
  - Multiplicador de custo com `nanoforge_cells` max: `0.50 -> 0.50` (sem efeito pratico por clamp)
- Tuning aplicado:
  - Rebalance de `baseCost`, `costMultiplier` e `maxLevel` das techs de Singularity.
  - Reducao do capstone global de `x8` para `x6` em `exo_mind_uplink`.
  - Rework da formula de `calculateCostReductionMultiplier` para aplicar `nanoforge_cells` apos o clamp pre-Singularity, mantendo seguranca de early-game.
- Resultado apos tuning:
  - Custo total techs Singularity: `506,351,498,750,000,000` CE
  - Razao Singularity/Cyberpunk: `54.30x`
  - Multiplicador de custo com `nanoforge_cells` max: `0.50 -> 0.40`
- Validacao tecnica:
  - `flutter analyze --no-fatal-infos`: passou (apenas infos legadas)
  - `flutter test`: passou (suite completa verde)

---

## STORY-9: QA, regressao e checklist de release
status: todo

Descricao:
Validar estabilidade, localizacao, persistencia e integridade de progressao.

Checklist:
- `flutter analyze`
- `flutter test`
- Teste manual: hire/merge/deploy/chamber/expedition/tech/era advance
- Save/load com progresso antigo e novo

Aceite:
- Sem erro de runtime em fluxo principal.
- Sem regressao em eras anteriores.
- Nenhum asset missing na era Singularidade.

Done when:
- Checklist fechado e status final do plano atualizado.

---

## STORY-10: Testes de cobertura das alteracoes + audits de qualidade
status: todo

Descricao:
Criar e/ou expandir testes para todos os arquivos e comportamentos alterados neste ciclo de Singularidade, e executar auditorias de qualidade para fechar o pacote com seguranca de regressao.

Escopo alvo:
- Cobertura de dominio para:
  - `WorkerEra.post_singularity` (nome de exibicao e compatibilidade de id)
  - `StationType.quantumSpire` (metadados e formulas principais)
  - Registro de workers de Singularity (`WorkerNameRegistry`)
  - Techs novas e formulas (`TechData`, `TechUpgrade`)
  - Identidade de expedicao de Singularity (`Expedition`)
- Cobertura de apresentacao para:
  - Mapeamentos de localizacao (PT/EN) da era/chamber
  - Resolvedor de icones (`WorkerIconHelper`)
  - Caminhos de background white-label de Singularity (`GameAssets`, `EraBackground`, `EraUnlockDialog`)

Checklist de execucao:
- `flutter test`
- `flutter analyze --no-fatal-infos`
- `python .agent/scripts/flutter-quality-audit.py`
- `python .agent/scripts/audit-app.py`

Aceite:
- Testes novos cobrindo os fluxos alterados adicionados e verdes.
- Nenhum erro bloqueante nas auditorias; warnings documentados com acao.
- Relatorio final com mapeamento `arquivo alterado -> teste correspondente`.

Done when:
- Suite de testes + audits executadas e anexadas com resultado no plano/PR.
