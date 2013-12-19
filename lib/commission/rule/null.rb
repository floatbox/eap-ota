# encoding: utf-8
# возвращаем это вместо null, если правило не найдено
Commission::Rule::Null = Commission::Rule.new(
  no_commission: 'не подошло ни одно правило',
  number: 0,
  source: __FILE__,
  # TODO убрать, если получится сделать дефолты
  agent: 0,
  subagent: 0,
  consolidator: 0,
  blanks: 0
)
