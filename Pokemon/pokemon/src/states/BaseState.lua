-- Estado base: define a interface que todos os estados do jogo implementam.
-- As subclasses sobrescrevem só o que precisam.

-- Todos os métodos são vazios por padrão
BaseState = Class{}

-- Construtor
function BaseState:init() end

-- Chamado quando o estado entra na pilha
function BaseState:enter() end

-- Chamado quando o estado sai da pilha
function BaseState:exit() end

-- Lógica por frame
function BaseState:update(dt) end

-- Desenho por frame
function BaseState:render() end
