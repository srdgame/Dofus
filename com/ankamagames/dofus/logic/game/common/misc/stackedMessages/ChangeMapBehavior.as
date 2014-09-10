package com.ankamagames.dofus.logic.game.common.misc.stackedMessages
{
   import com.ankamagames.jerakine.messages.Message;
   import com.ankamagames.atouin.messages.AdjacentMapClickMessage;
   import com.ankamagames.jerakine.types.positions.MapPoint;
   import com.ankamagames.berilia.frames.ShortcutsFrame;
   import com.ankamagames.atouin.utils.CellUtil;
   import com.ankamagames.dofus.misc.utils.EmbedAssets;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayMovementFrame;
   
   public class ChangeMapBehavior extends AbstractBehavior
   {
      
      public function ChangeMapBehavior() {
         super();
         type = STOP;
      }
      
      public var forceWalk:Boolean;
      
      override public function processInputMessage(pMsgToProcess:Message, pMode:String) : Boolean {
         var cellId:uint = 0;
         var walkingId:String = null;
         if((pendingMessage == null) && (pMsgToProcess is AdjacentMapClickMessage))
         {
            pendingMessage = pMsgToProcess;
            cellId = (pendingMessage as AdjacentMapClickMessage).cellId;
            position = MapPoint.fromCellId(cellId);
            this.forceWalk = ShortcutsFrame.ctrlKeyDown;
            walkingId = this.forceWalk?"_WALK":"";
            if(CellUtil.isLeftCol(cellId))
            {
               sprite = EmbedAssets.getSprite("CHECKPOINT_CLIP_LEFT" + walkingId);
            }
            else if(CellUtil.isRightCol(cellId))
            {
               sprite = EmbedAssets.getSprite("CHECKPOINT_CLIP_RIGHT" + walkingId);
            }
            else if(CellUtil.isBottomRow(cellId))
            {
               sprite = EmbedAssets.getSprite("CHECKPOINT_CLIP_BOTTOM" + walkingId);
            }
            else
            {
               sprite = EmbedAssets.getSprite("CHECKPOINT_CLIP_TOP" + walkingId);
            }
            
            
            return true;
         }
         return false;
      }
      
      override public function processOutputMessage(pMsgToProcess:Message, pMode:String) : Boolean {
         return false;
      }
      
      override public function copy() : AbstractBehavior {
         var cp:ChangeMapBehavior = new ChangeMapBehavior();
         cp.pendingMessage = this.pendingMessage;
         cp.position = this.position;
         cp.sprite = this.sprite;
         cp.forceWalk = this.forceWalk;
         return cp;
      }
      
      override public function processMessageToWorker() : void {
         var rpMovementFrame:RoleplayMovementFrame = Kernel.getWorker().getFrame(RoleplayMovementFrame) as RoleplayMovementFrame;
         rpMovementFrame.setForceWalkForNextMovement(this.forceWalk);
         super.processMessageToWorker();
      }
   }
}
