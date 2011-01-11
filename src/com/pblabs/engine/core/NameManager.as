/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.IEntityComponent;
    
    import flash.utils.Dictionary;
    
    /**
     * The name manager stores references to PBObjects that have been given
     * names. These PBObjects can be looked up by name.
     */
    public class NameManager
    {
        /**
         * The list of registered PBObjects.
         */
        public function get objectList():Dictionary
        {
            return _objects;
        }
        
        /**
         * Registers an entity under a specific name. If the name is in use, lookups will
         * return the last entity added under the name.
         * 
         * @param entity The entity to add.
         * @param name The name to register the entity under.
         */
        public function add(object:IPBObject):void
        {
            var isNameValid:Boolean = (object.name != null && object.name != "");
            var isAliasValid:Boolean = (object.alias != null && object.alias != "");
            
            if (isNameValid && _objects[object.name])
                Logger.warn(this, "add", "A PBObject with the name " + object.name + " already exists. Future lookups by this name will return the newest object. Did you mean to make an entity a template?");
            
            if(TemplateManager.VERBOSE_LOGGING)
                Logger.print(this, "Registering PBObject '" + object.name + "', alias '" + object.alias + "'");
            
            
            if(isNameValid)
                _objects[object.name] = object;
            
            if(isAliasValid)
                _objects[object.alias] = object;
        }
        
        /**
         * Removes an object from the manager.
         * 
         * @param entity The IPBObject to remove.
         */
        public function remove(object:IPBObject):void
        {
            // Unregister its alias, if it has one and the alias points to us.
            if (object.alias != null && object.alias != "" && _objects[object.alias] == object)
            {
                _objects[object.alias] = null;
                delete _objects[object.alias];                  
            }
            
            // And the normal name, if it is us.
            if(object.name != null && object.name != "" && _objects[object.name] == object )
            {
                _objects[object.name] = null;
                delete _objects[object.name];
            }
            
            unregisterAliases(object);
        }
        
        
        /**
         * Register an alias for an IPBObject 
         * @param object The object to register the alias for
         * @param alias The alias to register
         **/
        public function registerAlias(object:IPBObject, alias:String):void
        {
            if(alias == null || alias == "") 
            {
                Logger.warn(this, "registerAlias", "Attempt made to register invalid alias '"+alias+"'");
                return;
            }
            
            if(_objects[alias])
            {
                Logger.warn(this, "registerAlias","A PBObject with the name '" + alias + "' already exists ");
                return;
            }
            
            _objects[alias] = object;
            
            //Store the alias in the registeredAliases map
            if(!_registeredAliases[object])
                _registeredAliases[object] = [];
            _registeredAliases[object].push(alias);
        }
        
        /**
         * Unregister an alias for an IPBObject 
         * @param object The object to register the alias for.
         * @param alias The alias to unregister.
         **/		
        public function unregisterAlias(object:IPBObject, alias:String):void
        {
            // Check if the alias exists, points to the IPBObject and is an alias.
            if(_objects[alias] && _objects[alias] == object
                && _registeredAliases[object] && _registeredAliases[object].indexOf(alias) > -1)
            {
                _objects[alias] = null;
                delete _objects[alias];
                
                _registeredAliases[object].splice(_registeredAliases[object].indexOf(alias), 1);
                if(_registeredAliases[object].length < 1)
                    delete _registeredAliases[object];
            } 
            else 
            {
                Logger.warn(this, "unregisterAlias", "Attempt made to unregister alias '"+alias+"' but the object registered is not the same or the alias is not a registered alias.");
                return;
            }
        }
        /**
         * Unregister all aliases for an IPBObject 
         * @param object The IPBObject to unregister.
         **/
        public function unregisterAliases(object:IPBObject):void{
            if(!_registeredAliases[object])
                return;
            
            for each(var alias:String in  _registeredAliases[object])
            {
                _objects[alias] = null;
                delete _objects[alias];
            }
             
            delete _registeredAliases[object];
        }
        
        /**
         * Looks up a PBObject with the specified name.
         * 
         * @param name The name of the object to look up.
         * 
         * @return The object with the specified name, or null if it wasn't found.
         */
        public function lookup(name:String):*
        {
            return _objects[name];
        }
        
        /**
         * Turns a potentially used name and returns a related unused name. The
         * given name will have a number appended, with the number continually
         * incremented until an unused name is found.
         * 
         * @param name The name to validate.
         * 
         * @return The validated name. This is guaranteed to not be in use.
         */
        public function validateName(name:String):String
        {
            if (!_objects[name])
                return name;
            
            var index:int = 1;
            var testName:String = name + index;
            while (_objects[testName])
                testName = name + index++;
            
            return testName;
        }
        
        /**
         * Looks up a component on an entity that has been registered. The same
         * conditions apply as with the lookupComponentByType method on IEntity.
         * 
         * @param The name of the entity on which the component exists.
         * @param componentType The type of the component to lookup.
         * 
         * @see com.pblabs.engine.entity.IEntity#lookupComponentByType()
         */
        public function lookupComponentByType(name:String, componentType:Class):IEntityComponent
        {
            var entity:IEntity = lookup(name);
            if (!entity)
                return null;
            
            return entity.lookupComponentByType(componentType);
        }
        
        /**
         * Looks up components on an entity that has been registered. The same
         * conditions apply as with the lookupComponentsByType method on IEntity.
         * 
         * @param The name of the entity on which the component exists.
         * @param componentType The type of the components to lookup.
         * 
         * @see com.pblabs.engine.entity.IEntity#lookupComponentByType()
         */
        public function lookupComponentsByType(name:String, componentType:Class):Array
        {
            var entity:IEntity = lookup(name);
            if (!entity)
                return null;
            
            return entity.lookupComponentsByType(componentType);
        }      
        
        /**
         * Looks up a component on an entity that has been registered. The same
         * conditions apply as with the lookupComponentByName method on IEntity.
         * 
         * @param The name of the entity on which the component exists.
         * @param componentName The name of the component to lookup.
         * 
         * @see com.pblabs.engine.entity.IEntity#lookupComponentByName()
         */
        public function lookupComponentByName(name:String, componentName:String):IEntityComponent
        {
            var entity:IEntity = lookup(name);
            if (!entity)
                return null;
            
            return entity.lookupComponentByName(componentName);
        }
        
        private var _objects:Dictionary = new Dictionary();
        
        //Map from PBObject -> String[] that contains all registered aliases
        private var _registeredAliases:Dictionary = new Dictionary();
        
    }
}