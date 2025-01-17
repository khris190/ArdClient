Haven Resource 1 src �  Fac.java /* Preprocessed source code */
import haven.*;
import haven.resutil.Curiosity;

/* >tt: Fac */
public class Fac implements ItemInfo.InfoFactory {
    public ItemInfo build(ItemInfo.Owner owner, ItemInfo.Raw raw, Object... args) {
	int exp = ((Number)args[1]).intValue();
	int mw = ((Number)args[2]).intValue();
	int enc = ((Number)args[3]).intValue();
	int time = ((Number)args[4]).intValue();
	return(new Curiosity(owner, exp, mw, enc, time));
    }
}
code �  Fac ����   4 '
   
   
      <init> ()V Code LineNumberTable build   Owner InnerClasses ! Raw O(Lhaven/ItemInfo$Owner;Lhaven/ItemInfo$Raw;[Ljava/lang/Object;)Lhaven/ItemInfo; 
SourceFile Fac.java 	 
 java/lang/Number " # haven/resutil/Curiosity 	 $ Fac java/lang/Object % haven/ItemInfo$InfoFactory InfoFactory haven/ItemInfo$Owner haven/ItemInfo$Raw intValue ()I (Lhaven/ItemInfo$Owner;IIII)V haven/ItemInfo curio.cjava !         	 
          *� �            �       e     =-2� � 6-2� � 6-2� � 6-2� � 6� Y+� �               	 ! 
 ,       &        	    	   	codeentry 
   tt Fac   