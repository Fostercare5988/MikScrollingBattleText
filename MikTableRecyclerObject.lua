-------------------------------------------------------------------------------------
-- Title: Mik's Table Recyler Object
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-- Credits:
--  Thanks to tekkub, the author of compostLib.  I adapted much of his code for
--  this object.
-------------------------------------------------------------------------------------

-- ClassicAPIRequirement.lua checks the DLLs.
if not MSBT_REQUIREMENTS_MET then return end

-- Create "namespace."
MikTRO = {};

local setmetatable = setmetatable;
local type = type;
local next = next;

-- Set the __index property to the recycler object namespace so
-- when a new recycler object sets it metatable to the namespace
-- the recycler object inherits the functions in the namespace.
MikTRO.__index = MikTRO;


-- **********************************************************************************
-- Creates a recycler object. Up to maxEntries tables are kept; extra reclaimed
-- tables sit in a weak cache the garbage collector may empty.
-- **********************************************************************************
function MikTRO:NewRecyclerObject(maxEntries)
 local recyclerObject = {};
 recyclerObject.PrimaryCache = {};
 recyclerObject.PrimaryCacheSize = 0;
 recyclerObject.MaxEntries = maxEntries or 100;
 recyclerObject.OverflowCache = setmetatable({}, {__mode = "k"});
 recyclerObject.CachedTables = setmetatable({}, {__mode = "k"});
 setmetatable(recyclerObject, self);
 return recyclerObject;
end


-- **********************************************************************************
-- Removes a table from the cache and returns it.
-- **********************************************************************************
function MikTRO:AcquireTable()
 if (self.PrimaryCacheSize > 0) then
  local t = self.PrimaryCache[self.PrimaryCacheSize];
  self.PrimaryCache[self.PrimaryCacheSize] = nil;
  self.PrimaryCacheSize = self.PrimaryCacheSize - 1;
  self.CachedTables[t] = nil;
  return t;

 elseif (next(self.OverflowCache) ~= nil) then
  local t = next(self.OverflowCache);
  self.OverflowCache[t] = nil;
  self.CachedTables[t] = nil;
  return t;
 end

 return {};
end


-- **********************************************************************************
-- Erases a table and reclaims it into the cache. Subtables are NOT erased.
-- **********************************************************************************
function MikTRO:ReclaimTable(t)
 if (type(t) ~= "table" or self.CachedTables[t]) then
  return;
 end
 self.CachedTables[t] = true;
 table.wipe(t);

 if (self.PrimaryCacheSize >= self.MaxEntries) then
  self.OverflowCache[t] = true;
 else
  self.PrimaryCacheSize = self.PrimaryCacheSize + 1;
  self.PrimaryCache[self.PrimaryCacheSize] = t;
 end
end
