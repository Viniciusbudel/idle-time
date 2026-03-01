// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Fábrica do Tempo';

  @override
  String get loadingTimeline => 'Carregando Linha do Tempo...';

  @override
  String get chambers => 'CÂMARAS';

  @override
  String get factory => 'FÁBRICA';

  @override
  String get summon => 'INVOCAR';

  @override
  String get tech => 'TECNOLOGIA';

  @override
  String get prestige => 'PRESTÍGIO';

  @override
  String get currentOutput => 'PRODUÇÃO ATUAL';

  @override
  String get perSecond => '/ SEG';

  @override
  String get sysOnline => 'SISTEMA :: ONLINE';

  @override
  String get efficiency => 'EFIC';

  @override
  String get stability => 'ESTABILIDADE';

  @override
  String get systemUpgrade => 'UPGRADE DO SISTEMA';

  @override
  String get initUpgrade => 'UPGRADE';

  @override
  String get initializeExpansion => 'Iniciar protocolo de expansão?';

  @override
  String get lvl => 'NÍV';

  @override
  String get manageUnits => 'GERENCIAR UNIDADES';

  @override
  String get workerManagement => 'GERENCIAMENTO DE TRABALHADORES';

  @override
  String get mergeInstructions =>
      'Combine 3 trabalhadores da mesma raridade para criar 1 de raridade superior.';

  @override
  String get legacyUnitsDetected => 'UNIDADES LEGADAS DETECTADAS';

  @override
  String get legacyUnitsDescription =>
      'Adapte estes trabalhadores para a tecnologia da era atual para aumentar significativamente a produção.';

  @override
  String get refit => 'ADAPTAR';

  @override
  String available(int count) {
    return '$count Disponíveis';
  }

  @override
  String get needMoreToMerge => 'Necessário 3 da mesma era para combinar';

  @override
  String get merge => 'COMBINAR';

  @override
  String get mergeSuccessful => 'COMBINAÇÃO BEM-SUCEDIDA!';

  @override
  String unit(String rarity) {
    return 'Unidade $rarity';
  }

  @override
  String get production => 'PROD';

  @override
  String get excellent => 'EXCELENTE';

  @override
  String get techAugmentation => 'AUMENTO TECNOLÓGICO';

  @override
  String get systemUpgradesAvailable => 'UPGRADES DE SISTEMA DISPONÍVEIS';

  @override
  String get eraLocked => 'ERA BLOQUEADA';

  @override
  String get researchIncomplete => 'PESQUISA INCOMPLETA';

  @override
  String advanceTo(String era) {
    return 'AVANÇAR PARA $era';
  }

  @override
  String get cost => 'CUSTO';

  @override
  String get common => 'Comum';

  @override
  String get rare => 'Rara';

  @override
  String get epic => 'Épica';

  @override
  String get legendary => 'Lendária';

  @override
  String get paradox => 'Paradoxal';

  @override
  String get victorian => 'Era Steampunk';

  @override
  String get roaring20s => 'Anos 20 Vibrantes';

  @override
  String get atomicAge => 'Era Atômica';

  @override
  String get cyberpunk80s => 'Cyberpunk 80';

  @override
  String get neoTokyo => 'Neo-Tóquio';

  @override
  String get postSingularity => 'Pós-Singularidade';

  @override
  String get ancientRome => 'Roma Antiga';

  @override
  String get farFuture => 'Futuro Distante';

  @override
  String get chronoEnergy => 'Crono-Energia';

  @override
  String get timeShards => 'Fragmentos do Tempo';

  @override
  String get paradoxPoints => 'Pontos de Paradoxo';

  @override
  String get base => 'Base';

  @override
  String get techBonus => 'Bônus Tecnológico';

  @override
  String get ceSec => 'CE/SEG';

  @override
  String get shards => 'SHARDS';

  @override
  String get mergeFailed => 'Falha na combinação';

  @override
  String get workerProtocols => 'PROTOCOLOS DE TRABALHO';

  @override
  String get online => 'ATIVO';

  @override
  String get basicLoopName => 'Câmara de Loop Básico';

  @override
  String get dualHelixName => 'Câmara de Hélice Dupla';

  @override
  String get nuclearReactorName => 'Reator de Fusão Nuclear';

  @override
  String get paradoxAmplifierName => 'Amplificador de Paradoxo';

  @override
  String get timeDistortionName => 'Campo de Distorção Temporal';

  @override
  String get dataNodeName => 'Nó de Dados';

  @override
  String get synthLabName => 'Laboratório Sintético';

  @override
  String get neonCoreName => 'Núcleo Neon';

  @override
  String get riftGeneratorName => 'Gerador de Fenda';

  @override
  String get chronoMasteryName => 'Maestria Cronológica';

  @override
  String get chronoMasteryDescription => '+10% de produção de CE por ponto';

  @override
  String get riftStabilityName => 'Estabilidade de Fenda';

  @override
  String get riftStabilityDescription => '-5% de acúmulo de paradoxo por ponto';

  @override
  String get eraInsightName => 'Visão de Era';

  @override
  String get eraInsightDescription => '+1 era inicial desbloqueada por ponto';

  @override
  String get offlineBonusName => 'Memória Temporal';

  @override
  String get offlineBonusDescription => '+10% de eficiência offline por ponto';

  @override
  String get timekeepersFavorName => 'Favor do Guardião do Tempo';

  @override
  String get timekeepersFavorDescription =>
      'Raids mais fáceis, melhores recompensas';

  @override
  String get timelineCollapse => 'COLAPSO DA LINHA DO TEMPO';

  @override
  String get prestigeDescription =>
      'Reinicie sua linha do tempo para ganhar Pontos de Prestígio (PP).\nPP aumenta a produção em 10% por ponto.';

  @override
  String get estimatedReward => 'RECOMPENSA ESTIMADA';

  @override
  String get initiateCollapse => 'INICIAR COLAPSO';

  @override
  String get prestigeRequirement =>
      'Requer mais ganhos vitalícios para colapsar.';

  @override
  String get activeWorkforce => 'FORÇA DE TRABALHO ATIVA';

  @override
  String get totalDailyYield => 'RENDIMENTO DIÁRIO TOTAL';

  @override
  String get operationalChambers => 'CÂMARAS OPERACIONAIS';

  @override
  String get systemStatus => 'STATUS DO SISTEMA';

  @override
  String get allSystemsOptimal => 'SISTEMAS EXCELENTES';

  @override
  String get noActiveChambers => 'Nenhuma câmara ativa detectada.';

  @override
  String get deployWorkersToStart =>
      'Aloque trabalhadores para iniciar a produção.';

  @override
  String get active => 'ATIVO';

  @override
  String get hireNewUnit => 'RECRUTAR NOVA UNIDADE';

  @override
  String get noUnitsDetected => 'NENHUMA UNIDADE DETECTADA';

  @override
  String get commandCenter => 'CENTRO DE COMANDO';

  @override
  String get activeUnits => 'UNIDADES ATIVAS';

  @override
  String get eraUnlocked => 'ERA DESBLOQUEADA';

  @override
  String get initializePrimaryChamber =>
      'Inicialize a Câmara Primária para começar a produção.';

  @override
  String get initializeSystem => 'INICIALIZAR SISTEMA';

  @override
  String get insufficientCE => 'CE insuficiente para o upgrade!';

  @override
  String get factoryFloorFull => 'Chão da Fábrica Lotado (Máx 5 Câmaras)!';

  @override
  String needCEToConstruct(Object cost) {
    return 'Necessário $cost CE para construir!';
  }

  @override
  String get statusLabel => 'STATUS:';

  @override
  String get optimal => 'EXCELENTE';

  @override
  String get stable => 'ESTÁVEL';

  @override
  String get critical => 'CRÍTICO';

  @override
  String get idle => 'OCIOSO';

  @override
  String get repair => 'REPARAR';

  @override
  String get assign => 'ATRIBUIR';

  @override
  String get upgrade => 'UPGRADE';

  @override
  String advanceToEra(Object era) {
    return 'AVANÇAR PARA $era';
  }

  @override
  String get timelineMaximized => 'LINHA DO TEMPO NO MÁXIMO';

  @override
  String get advanceTimeline => 'AVANÇAR LINHA DO TEMPO';

  @override
  String get techIncomplete => 'TECNOLOGIA INCOMPLETA';

  @override
  String get requirement => 'REQUISITO';

  @override
  String get assignWorker => 'ASSIGN WORKER';

  @override
  String selectUnitFor(Object station) {
    return 'Selecione uma unidade para $station';
  }

  @override
  String get noIdleWorkers => 'NENHUMA UNIDADE EM IDLE';

  @override
  String get hireMoreToAssign => 'Contrate mais unidades para fazer o assign';

  @override
  String get welcomeBack => 'WELCOME BACK';

  @override
  String awayFor(Object duration) {
    return 'Você esteve fora por $duration';
  }

  @override
  String get ceCollected => 'CHRONO-ENERGY COLETADA';

  @override
  String offlineEfficiency(Object percent) {
    return '$percent% de eficiência offline';
  }

  @override
  String get collect => 'COLETAR';

  @override
  String get timelineUnlocked => 'TIMELINE DESBLOQUEADA';

  @override
  String get newEraAvailable =>
      'Uma nova era está disponível para exploração. Viaje agora para acessar novas tecnologias e recursos.';

  @override
  String get travelToEra => 'VIAJAR PARA ERA';

  @override
  String get later => 'DEPOIS';

  @override
  String get recallWorker => 'RECALL WORKER';

  @override
  String get noStationsAvailable => 'NENHUMA STATION DISPONÍVEL';

  @override
  String get buildStationsToStart => 'Construa estações na aba Factory';

  @override
  String get upgradeStation => 'UPGRADE STATION';

  @override
  String get productionBonus => 'Bônus de Produção';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get confirm => 'CONFIRMAR';

  @override
  String nextEffect(Object label, Object percent) {
    return 'PRÓXIMO: +$percent% $label';
  }

  @override
  String get automationEffect => 'AUT0-COLETA';

  @override
  String get efficiencyEffect => 'PRODUÇÃO';

  @override
  String get timeWarpEffect => 'VELOCIDADE';

  @override
  String get costReductionEffect => 'PREÇO UPGRADE';

  @override
  String get offlineEffect => 'GANHOS OFFLINE';

  @override
  String get clickPowerEffect => 'PODER MANUAL';

  @override
  String get eraUnlockEffect => 'LIBERAÇÃO DE ERA';

  @override
  String get manhattanEffect => 'MULTIPLICADOR ATÔMICO';

  @override
  String get statusDeployed => 'ALOCADO';

  @override
  String get statusIdle => 'IDLE';

  @override
  String get deploy => 'DEPLOY';

  @override
  String get full => 'FULL';

  @override
  String get settings => 'CONFIGURAÇÕES';

  @override
  String get settingsGeneral => 'GERAL';

  @override
  String get settingsData => 'DADOS';

  @override
  String get settingsAbout => 'SOBRE';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsResetProgress => 'Resetar Progresso';

  @override
  String get settingsReset => 'RESETAR';

  @override
  String get settingsResetConfirmTitle => 'RESETAR TUDO?';

  @override
  String get settingsResetConfirmBody =>
      'Isso apagará permanentemente todo progresso, trabalhadores e recursos. Esta ação não pode ser desfeita.';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsDeveloper => 'Desenvolvedor';

  @override
  String get tutorialWelcomeTitle => 'BEM-VINDO, CRONO-ENGENHEIRO';

  @override
  String get tutorialWelcomeBody =>
      'A linha do tempo está instável. Precisamos estabelecer um loop de produção. Toque em qualquer lugar para inicializar.';

  @override
  String get tutorialHireTitle => 'RECRUTAR FORÇA';

  @override
  String get tutorialHireBody =>
      'Produtividade zero. Precisamos de trabalhadores. Acesse a FENDA TEMPORAL para invocar uma unidade.';

  @override
  String get tutorialAssignTitle => 'DADOS: UNIDADE OCIOSA';

  @override
  String get tutorialAssignBody =>
      'Temos um trabalhador, mas ele não está fazendo nada. Arraste-o para uma Câmara para gerar Crono-Energia.';

  @override
  String get tutorialProduceTitle => 'SISTEMA: ONLINE';

  @override
  String get tutorialProduceBody =>
      'Produção estável. Toque no REATOR para acelerar o tempo manualmente e coletar energia.';

  @override
  String get tutorialGoalTitle => 'OBJETIVO: COLAPSO';

  @override
  String get tutorialGoalBody =>
      'Bom trabalho. Seu objetivo é alcançar 1 MILHÃO DE CE para causar um EVENTO DE PRESTÍGIO. Boa sorte.';

  @override
  String get achievements => 'CONQUISTAS';

  @override
  String get ack => 'OK';

  @override
  String get activeTitle => 'Ativas';

  @override
  String get all => 'TODOS';

  @override
  String artifactRollChance(int percent) {
    return 'Chance de artefato: $percent%';
  }

  @override
  String get auto => 'Auto';

  @override
  String availableMissions(int count) {
    return 'Missoes Disponiveis ($count)';
  }

  @override
  String get awesome => 'INCRIVEL';

  @override
  String get chronoEnergyUpper => 'ENERGIA CRONO';

  @override
  String get claim => 'COLETAR';

  @override
  String get claimAll => 'COLETAR TUDO';

  @override
  String claimedRewardsCount(int count) {
    return '$count recompensa(s) coletada(s)';
  }

  @override
  String get completed => 'CONCLUIDAS';

  @override
  String confirmSelectedWorkers(int selected, int required) {
    return 'Confirmar ($selected/$required)';
  }

  @override
  String get confirmUpgrade => 'CONFIRMAR UPGRADE';

  @override
  String get craft => 'CRIAR';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String expeditionCompletedTitle(String slot, String ce, int shards) {
    return '$slot | +$ce CE | +$shards TS';
  }

  @override
  String expeditionFailureLoss(int workers, int artifacts) {
    return 'Perdeu $workers trabalhador(es) e $artifacts artefato(s)';
  }

  @override
  String get expeditionReward => 'RECOMPENSA DA EXPEDICAO';

  @override
  String expeditionRiskBadge(
    String risk,
    String ceMultiplier,
    int shards,
    int artifactChance,
  ) {
    return '$risk  x$ceMultiplier  +${shards}TS  $artifactChance%';
  }

  @override
  String expeditionStarted(String slot, String risk, int workers) {
    return '$slot iniciada ($risk) com $workers trabalhador(es)';
  }

  @override
  String get expeditionStatus => 'STATUS DA EXPEDICAO';

  @override
  String expeditionWorkersAssigned(
    int workers,
    String ceMultiplier,
    int shards,
    int artifactChance,
  ) {
    return '$workers trabalhador(es) alocado(s) | perfil: x$ceMultiplier CE, +$shards TS, $artifactChance% artefato';
  }

  @override
  String expeditionWorkersReady(int required, int available) {
    return 'Precisa de $required ocioso(s) | $available pronto(s)';
  }

  @override
  String expeditionWorkersReadyInsufficient(int required, int available) {
    return 'Precisa de $required ocioso(s) | apenas $available pronto(s)';
  }

  @override
  String get failureReportAcknowledged => 'Relatorio de falha confirmado';

  @override
  String get hireSuccessful => 'CONTRATACAO BEM-SUCEDIDA!';

  @override
  String get holdPressInspectTapEquip =>
      'Segure para inspecionar ? Toque para equipar';

  @override
  String get idleTitle => 'Ocioso';

  @override
  String get initiateExpedition => 'INICIAR EXPEDICAO';

  @override
  String labelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get manage => 'GERENCIAR';

  @override
  String get missionControl => 'Controle de Missoes';

  @override
  String get missions => 'MISSOES';

  @override
  String nextCompletion(String slot, String duration) {
    return 'Proxima conclusao: $slot em $duration';
  }

  @override
  String get noActiveExpeditions => 'Nenhuma expedicao ativa';

  @override
  String noArtifactsByFilter(String filter) {
    return 'Nenhum artefato $filter no inventario.';
  }

  @override
  String get noChambersYet => 'Nenhuma camara ainda';

  @override
  String get noRewardsWaiting => 'Nenhuma recompensa aguardando';

  @override
  String noWorkersByRarity(String rarity) {
    return 'Sem trabalhadores $rarity';
  }

  @override
  String get paradoxPointsAbbrev => 'PP';

  @override
  String get readyTitle => 'Pronta';

  @override
  String resourceYieldLabel(String ce) {
    return 'RENDIMENTO: $ce CE';
  }

  @override
  String get resourceYieldUnavailable => 'RENDIMENTO: --';

  @override
  String get salvage => 'RECICLAR';

  @override
  String salvagedArtifactDust(int dust) {
    return 'Artefato reciclado: +$dust Po';
  }

  @override
  String get searchArtifacts => 'BUSCAR ARTEFATOS...';

  @override
  String selectWorkers(int required) {
    return 'Selecione $required trabalhador(es)';
  }

  @override
  String selectedWorkers(int selected, int required) {
    return 'Selecionados $selected/$required';
  }

  @override
  String get tapWorkerIconsHint =>
      'Toque nos icones acima para atribuir ou trocar a equipe.';

  @override
  String get timeShardsAbbrev => 'TS';

  @override
  String get timeShardsUpper => 'FRAGMENTOS DO TEMPO';

  @override
  String get unableClaimExpedition =>
      'Nao foi possivel coletar o resultado da expedicao.';

  @override
  String get unableStartExpedition =>
      'Nao foi possivel iniciar a expedicao com os trabalhadores selecionados.';

  @override
  String get unassign => 'REMOVER';

  @override
  String get welcome => 'BEM-VINDO';

  @override
  String allArtifactSlotsFilled(int slots) {
    return 'TODOS OS $slots SLOTS PREENCHIDOS - Desequipe um artefato primeiro.';
  }

  @override
  String get craftFailedDustOrInventory =>
      'Falha na criacao (po ou limite de inventario).';

  @override
  String upgradeMaxed(String title) {
    return '$title no maximo';
  }

  @override
  String upgradeCostsPp(String title, int cost) {
    return '$title custa $cost PP';
  }

  @override
  String get locked => 'BLOQUEADO';

  @override
  String prestigesCount(int count) {
    return 'Prestigios: $count';
  }

  @override
  String activeExpeditions(int count) {
    return 'Expedicoes Ativas ($count)';
  }

  @override
  String queuedRewards(String ce, int shards) {
    return 'Recompensas na fila: +$ce CE | +$shards TS';
  }

  @override
  String successProbabilityLabel(int percent) {
    return 'CHANCE DE SUCESSO: $percent%';
  }

  @override
  String expeditionFailedTitle(String slot) {
    return '$slot | FALHA';
  }

  @override
  String get max => 'MAX';

  @override
  String get retrofitProtocol => 'PROTOCOLO DE RETROFIT';

  @override
  String get upgradeLegacyUnitPrompt =>
      'Atualizar unidade legada para os padroes temporais atuais?';

  @override
  String get current => 'ATUAL';

  @override
  String get upgraded => 'APRIMORADA';

  @override
  String get techTreeChronalStabilizer => 'Estabilizador Cronal';

  @override
  String get techTreeChronalStabilizerDescription =>
      'Reduz o acumulo de paradoxo em 15%';

  @override
  String get techTreeQuantumDrill => 'Broca Quantica';

  @override
  String get techTreeQuantumDrillDescription =>
      'Aumenta a eficiencia de mineracao em 25%';

  @override
  String get techTreeNeuralNetwork => 'Rede Neural';

  @override
  String get techTreeNeuralNetworkDescription =>
      'Trabalhadores automatizam tarefas 10% mais rapido';

  @override
  String techTreeCostCe(String amount) {
    return '$amount CE';
  }

  @override
  String techCost(String value) {
    return 'CUSTO: $value';
  }

  @override
  String techCostCe(String value) {
    return 'CUSTO: $value CE';
  }
}
