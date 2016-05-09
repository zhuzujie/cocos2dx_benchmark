
local ComponentBase = cc.import(".ComponentBase")
local SpriteComponent = cc.class("cc.Sprite", ComponentBase)

function SpriteComponent:ctor(sprite)
    SpriteComponent.super.ctor(self)
    self.node = sprite
end

function SpriteComponent:bind(target)
    local node = self.node
    target:addChild(node)
    node:setAnchorPoint(target:getAnchorPoint())
    node:setColor(target:getColor())
end

return SpriteComponent
