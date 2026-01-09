return {
  -- 复合节点
  Parallel = require "scripts.lualib.behavior3.nodes.composites.parallel",
  Selector = require "scripts.lualib.behavior3.nodes.composites.selector",
  Sequence = require "scripts.lualib.behavior3.nodes.composites.sequence",

  -- 装饰节点
  Not           = require "scripts.lualib.behavior3.nodes.decorators.not",
  AlwaysFail    = require "scripts.lualib.behavior3.nodes.decorators.always_fail",
  AlwaysSuccess = require "scripts.lualib.behavior3.nodes.decorators.always_success",

  -- 条件节点
  Cmp = require "scripts.lualib.behavior3.nodes.conditions.cmp",

  -- 行为节点
  Log  = require "scripts.lualib.behavior3.nodes.actions.log",
  Wait = require "scripts.lualib.behavior3.nodes.actions.wait",
}