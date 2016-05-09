
local Assets = cc.class("cc.creator.Assets")

local Factory = cc.import(".filters.Factory")
local Connector = cc.import(".filters.Connector")

local _assert = assert
local _error = error

function Assets:ctor(base)
    self.base = base or ""
    if self.base ~= "" and string.sub(self.base, -1) ~= "." then
        self.base = self.base .. "."
    end

    self.assets  = require(self.base .. "assets.assets")
    self.files   = require(self.base .. "assets.files")
    self.scenes  = require(self.base .. "assets.scenes")
    self.prefabs = require(self.base .. "assets.prefabs")
end

function Assets:getLaunchSceneUrl()
    return self.scenes.__launchSceneUrl
end

function Assets:createScene(url)
    local uuid = self:getSceneUUID(url)
    local asset = self:getAsset(uuid)
    return self:createAsset(asset)
end

function Assets:createAsset(asset)
    assert(asset and asset.__type__ == "__js_array__", string.format("Assets:createAsset() - invalid asset"));

    local objs = {}
    local refs = asset.__js_array__
    for id, val in ipairs(refs) do
        if not objs[id] then
            objs[id] = self:_createObject(val, id, refs)
        end
    end

    for id, obj in ipairs(objs) do
        self:_bindComponent(obj, refs[id], refs)
        self:_connectObjects(objs, id, refs)
    end

    return objs[1]
end

function Assets:getSceneUUID(url)
    local uuid = self.scenes[url]
    _assert(uuid, string.format("creator.Assets:getSceneUUID() - not found uuid for scene '%s'", url))
    return uuid
end

function Assets:getAsset(uuid)
    local asset = self.assets[uuid]
    _assert(asset, string.format("creator.Assets:getAsset() - not found asset for uuid '%s'", uuid))
    return asset
end

function Assets:getFile(uuid)
    local file = self.files[uuid]
    _assert(file, string.format("creator.Assets:getFile() - not found file for uuid '%s'", uuid))
    return file
end

function Assets:_createObject(asset, id, refs)
    local objtype = asset.__type__
    local factory = Factory[objtype]
    if not factory then
        cc.printwarn("Assets:_createObject() - not support create type '%s'", objtype)
        return nil
    end

    cc.printdebug("[Assets] create object %s[%s]", objtype, tostring(id or ""))
    local obj = factory(asset, self)
    obj.__id = id
    return obj
end

function Assets:_bindComponent(obj, asset, refs)
    if not asset._components then return end

    obj.components = {}
    for _, componentAsset in ipairs(asset._components) do
        local component = self:_createObject(componentAsset)
        obj.components[componentAsset.__type__] = component
        component:bind(obj)
    end
end

function Assets:_connectObjects(objs, parentId, refs)
    local connector = Connector[refs[parentId].__type__]
    if not connector then return end
    connector(objs, parentId, refs)
end

return Assets