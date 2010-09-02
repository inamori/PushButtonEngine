/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.time
{

    import com.pblabs.engine.core.EntityComponent;
    
    /**
     * Base class for components that need to perform actions every tick. This
     * needs to be subclassed to be useful.
     */
    public class TickedComponent extends EntityComponent implements ITickedObject
    {
        [Inject]
        public var processManager:IProcessManager;
        
        /**
         * The update priority for this component. Higher numbered priorities have
         * onInterpolateTick and onTick called before lower priorities.
         */
        public var updatePriority:Number = 0.0;
        
        private var _registerForUpdates:Boolean = true;
        private var _isRegisteredForUpdates:Boolean = false;
        
        /**
         * Set to register/unregister for tick updates.
         */
        public function set registerForTicks(value:Boolean):void
        {
            _registerForUpdates = value;
            
            if(_registerForUpdates && !_isRegisteredForUpdates)
            {
                // Need to register.
                _isRegisteredForUpdates = true;
                processManager.addTickedObject(this, updatePriority);
            }
            else if(!_registerForUpdates && _isRegisteredForUpdates)
            {
                // Need to unregister.
                _isRegisteredForUpdates = false;
                processManager.removeTickedObject(this);
            }
        }
        
        /**
         * @private
         */
        public function get registerForTicks():Boolean
        {
            return _registerForUpdates;
        }
        
        /**
         * @inheritDoc
         */
        public function onTick(deltaTime:Number):void
        {
        }
        
        override protected function onAdd():void
        {
            super.onAdd();
            
            // This causes the component to be registerd if it isn't already.
            registerForTicks = registerForTicks;
        }
        
        override protected function onRemove():void
        {
            super.onRemove();
            
            // Make sure we are unregistered.
            registerForTicks = false;
        }
    }
}