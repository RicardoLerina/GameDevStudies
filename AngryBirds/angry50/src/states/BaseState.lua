-- Estado base: define a interface que todos os estados implementam.

-- Métodos vazios que as subclasses sobrescrevem
BaseState = Class{}

-- Construtor
function BaseState:init() end

-- Chamado ao entrar no estado
function BaseState:enter() end

-- Chamado ao sair do estado
function BaseState:exit() end

-- Lógica por frame
function BaseState:update(dt) end

-- Desenho por frame
function BaseState:render() end
