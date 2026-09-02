-------------------------------------------------------------------------------------
-- Title: Mik's Table Recyler Object
-- Author: Mik, Fostercare5988
-- Maintainer: Fostercare5988
-- Credits:
--  Thanks to tekkub, the author of compostLib.  I adapted much of his code for
--  this object.
-------------------------------------------------------------------------------------

-- Create "namespace."
MikTRO = {};

local setmetatable = setmetatable;
local type = type;
local next = next;
local pairs = pairs;
local tinsert = table.insert;
local tsetn = table.setn or function(t, n) end;

-- Set the __index property to the recycler object namespace so
-- when a new recycler object sets it metatable to the namespace
-- the recycler object inherits the functions in the namespace.
MikTRO.__index = MikTRO;


-- **********************************************************************************
-- Creates a recycler object.
-- **********************************************************************************
function MikTRO:NewRecyclerObject(maxEntries)
 -- Create a table to use.
 local recyclerObject = {};

 -- Create a table to hold the cache entries and set its max permanent size.
 recyclerObject.PrimaryCache = {};
 recyclerObject.PrimaryCacheSize = 0;
 recyclerObject.MaxEntries = maxEntries or 100;

 -- Create some variables to hold stats.
 recyclerObject.NumNew = 0;
 recyclerObject.NumRecycled = 0;
 recyclerObject.NumErased = 0;
 recyclerObject.NumReclaimed = 0;
 recyclerObject.AmountMemFreed = 0;

 -- Create a table to hold overflow entries.
 recyclerObject.OverflowCache = {};
 setmetatable(recyclerObject.OverflowCache, {__mode = "v"});

 -- Set the meta table for the cache object.
 setmetatable(recyclerObject, self);

 -- Return the recycler object.
 return recyclerObject;
end


-- **********************************************************************************
-- Removes a table from the cache and returns it.
-- **********************************************************************************
function MikTRO:AcquireTable()
 if (self.PrimaryCacheSize > 0) then
  self.NumRecycled = self.NumRecycled + 1;
  local t = self.PrimaryCache[self.PrimaryCacheSize];
  self.PrimaryCache[self.PrimaryCacheSize] = nil;
  self.PrimaryCacheSize = self.PrimaryCacheSize - 1;
  return t;

 elseif (next(self.OverflowCache) ~= nil) then
  self.NumRecycled = self.NumRecycled + 1;
  local k, t = next(self.OverflowCache);
  self.OverflowCache[k] = nil;
  return t;

 else
  self.NumNew = self.NumNew + 1;
  return {};
 end
end


-- **********************************************************************************
-- Reclaims a table into the cache.
-- **********************************************************************************
function MikTRO:ReclaimTable(t)
 if (type(t) ~= "table") then
  return;
 end

 -- Erase the passed table.
 self:EraseTable(t);

 -- Check if the primary cache is already full.
 if (self.PrimaryCacheSize >= self.MaxEntries) then
  tinsert(self.OverflowCache, t);
 else
  self.PrimaryCacheSize = self.PrimaryCacheSize + 1;
  self.PrimaryCache[self.PrimaryCacheSize] = t;
 end

 self.NumReclaimed = self.NumReclaimed + 1;
end


-- **********************************************************************************
-- Erases the passed table. Subtables are NOT erased.
-- **********************************************************************************
function MikTRO:EraseTable(t)
 if (type(t) ~= "table") then
  return;
 end

 if table.wipe then
  table.wipe(t);
 else
  for key in pairs(t) do
   t[key] = nil;
  end
  tsetn(t, 0);
 end
 self.NumErased = self.NumErased + 1;
end


-- **********************************************************************************
-- Prints stats.
-- **********************************************************************************
function MikTRO:PrintStats()
 local overflowSize = 0;
 for _ in pairs(self.OverflowCache) do
  overflowSize = overflowSize + 1;
 end

 DEFAULT_CHAT_FRAME:AddMessage(string.format(
  "|cff00ff00New Tables: %d|r  |cffffff00Recycled Tables: %d|r  |cff00ffffCached Tables: %d|r  |cffff0000Overflow Tables: %d|r  |cff888888Erased Tables: %d|r  |cffff00ffMemory Saved: %d KiB|r",
  self.NumNew,
  self.NumRecycled,
  self.PrimaryCacheSize,
  overflowSize,
  self.NumErased,
  self.AmountMemFreed + ((32/1024) * self.NumRecycled)));
end


-- **********************************************************************************
-- Checks if there are any tables in the overflow cache.
-- **********************************************************************************
function MikTRO:TablesInOverflow()
 return next(self.OverflowCache) ~= nil;
end