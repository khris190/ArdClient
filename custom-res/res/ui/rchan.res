Haven Resource 1 src �  RealmChannel.java /* Preprocessed source code */
package haven.res.ui.rchan;

import haven.*;
import java.util.*;
import java.awt.Color;
import java.awt.font.TextAttribute;

/* >wdg: RealmChannel */
public class RealmChannel extends ChatUI.MultiChat {
    private final Map<Integer, String> pnames = new HashMap<>();

    public RealmChannel(String name) {
	super(true, name, 0);
    }

    public static Widget mkwidget(UI ui, Object[] args) {
	String name = (String)args[0];
	return(new RealmChannel(name));
    }

    public class PNamedMessage extends Message {
	public final int from;
	public final String text;
	public final int w;
	public final Color col;
	private String cn;
	private Text r = null;

	public PNamedMessage(int from, String text, Color col, int w) {
	    this.from = from;
	    this.text = text;
	    this.w = w;
	    this.col = col;
	}

	private double lnmck = 0;
	public Text text() {
	    double now = Utils.rtime();
	    if((r == null) || (now - lnmck > 1)) {
		BuddyWnd.Buddy b = getparent(GameUI.class).buddies.find(from);
		String nm = null;
		if((nm == null) && (b != null))
		    nm = b.name;
		if((nm == null) && pnames.containsKey(Integer.valueOf(from)))
		    nm = pnames.get(Integer.valueOf(from));
		if(nm == null)
		    nm = "???";
		if((r == null) || !nm.equals(cn)) {
		    r = ChatUI.fnd.render(RichText.Parser.quote(String.format("%s: %s", nm, text)), w, TextAttribute.FOREGROUND, col);
		    cn = nm;
		}
	    }
	    return(r);
	}

	public Tex tex() {
	    return(text().tex());
	}

	public Coord sz() {
	    if(r == null)
		return(text().sz());
	    else
		return(r.sz());
	}
    }

    public PNamedMessage msgbyname(String nm) {
	for(ListIterator<Message> i = msgs.listIterator(msgs.size()); i.hasPrevious();) {
	    Message cur = i.previous();
	    if(cur instanceof PNamedMessage) {
		PNamedMessage msg = (PNamedMessage)cur;
		if((msg.cn != null) && msg.cn.equals(nm))
		    return(msg);
	    }
	}
	return(null);
    }

    public static class UserError extends Exception {
	public UserError(String fmt, Object... args) {
	    super(String.format(fmt, args));
	}
    }

    public static int parsedur(String d) {
	int m;
	switch(d.substring(d.length() - 1)) {
	case "s":
	    m = 1; break;
	case "m":
	    m = 60; break;
	case "h":
	    m = 3600; break;
	case "d":
	    m = 86400; break;
	case "w":
	    m = 604800; break;
	case "M":
	    m = 2419200; break;
	default:
	    m = 0;
	}
	if(m == 0) {
	    m = 1;
	} else {
	    d = d.substring(0, d.length() - 1);
	}
	return(Integer.parseInt(d) * m);
    }

    public static final Color wcol = new Color(255, 128, 0);
    public void cmd(String[] argv) {
	try {
	    switch(argv[0]) {
	    case "rename": {
		if(argv.length < 3)
		    throw(new UserError("usage: rename NAME NEW-NAME"));
		PNamedMessage msg = msgbyname(argv[1]);
		if(msg == null)
		    throw(new UserError("%s: no such name", argv[1]));
		pnames.put(msg.from, argv[2]);
		break;
	    }
	    case "ban": {
		if(argv.length < 2)
		    throw(new UserError("usage: ban NAME [DURATION]"));
		PNamedMessage msg = msgbyname(argv[1]);
		if(msg == null)
		    throw(new UserError("%s: no such name", argv[1]));
		int dur = 3600;
		if(argv.length > 2)
		    dur = parsedur(argv[2]);
		wdgmsg("ban", msg.from, dur);
		break;
	    }
	    case "unban": {
		if(argv.length < 2)
		    throw(new UserError("usage: unban NAME"));
		PNamedMessage msg = msgbyname(argv[1]);
		if(msg == null)
		    throw(new UserError("%s: no such name", argv[1]));
		wdgmsg("unban", msg.from);
		break;
	    }
	    default:
		throw(new UserError("%s: no such command", argv[0]));
	    }
	} catch(UserError e) {
	    append(e.getMessage(), wcol);
	} catch(Exception e) {
	    append(String.format("Error: %s", e), Color.RED);
	}
    }

    public void send(String msg) {
	if((msg.length() > 0) && (msg.charAt(0) == '/')) {
	    String[] argv = Utils.splitwords(msg.substring(1));
	    if((argv != null) && (argv.length > 0))
		cmd(argv);
	} else {
	    super.send(msg);
	}
    }

    public void uimsg(String msg, Object... args) {
	if(msg == "msg") {
	    Integer from = (Integer)args[0];
	    String line = (String)args[1];
	    String pname = null;
	    if(args.length > 2)
		pname = (String)args[2];
	    if(from == null) {
		append(new MyMessage(line, iw()));
	    } else {
		if((pname != null) && !pnames.containsKey(from))
		    pnames.put(from, pname);
		Message cmsg = new PNamedMessage(from, line, fromcolor(from), iw());
		append(cmsg);
		if(urgency > 0)
		    notify(cmsg, urgency);
	    }
	} else if(msg == "err") {
	    String err = (String)args[0];
	    Message cmsg = new SimpleMessage(err, wcol, iw());
	    append(cmsg);
	    notify(cmsg, 3);
	} else if(msg == "enter") {
	} else if(msg == "leave") {
	} else {
	    super.uimsg(msg, args);
	}
    }

    private static final Indir<Resource> icon = Resource.classres(RealmChannel.class).pool.load("gfx/hud/chat/rlm-p", 1);
    public Resource.Image icon() {
	return(icon.get().layer(Resource.imgc));
    }
}
code �
  haven.res.ui.rchan.RealmChannel$PNamedMessage ����   4 �	 ! C	 ! D
 " E	 ! F	 ! G	 ! H	 ! I	 ! J	 ! K
 L M N
 O P	  Q
 R S	 T U
 O V
 W X Y Z Y [ \ ]
  ^	 _ ` a b
  c
 d e	 f g
 h i
 ! j
 k l
 k m n p from I text Ljava/lang/String; w col Ljava/awt/Color; cn r Lhaven/Text; lnmck D this$0 !Lhaven/res/ui/rchan/RealmChannel; <init> H(Lhaven/res/ui/rchan/RealmChannel;ILjava/lang/String;Ljava/awt/Color;I)V Code LineNumberTable ()Lhaven/Text; StackMapTable t \ tex ()Lhaven/Tex; sz ()Lhaven/Coord; 
access$100 PNamedMessage InnerClasses C(Lhaven/res/ui/rchan/RealmChannel$PNamedMessage;)Ljava/lang/String; 
SourceFile RealmChannel.java * & / 0 1 u + , - . # $ % & ' $ ( ) v w x haven/GameUI y z { | } ~  � t � & � � � � � � � � � � java/lang/String ??? � � � � � %s: %s java/lang/Object � � � � � � � � � � � % 5 � 9 : ; < -haven/res/ui/rchan/RealmChannel$PNamedMessage � haven/ChatUI$Channel$Message Channel Message Buddy haven/BuddyWnd$Buddy ()V haven/Utils rtime ()D haven/res/ui/rchan/RealmChannel 	getparent !(Ljava/lang/Class;)Lhaven/Widget; buddies Lhaven/BuddyWnd; haven/BuddyWnd find (I)Lhaven/BuddyWnd$Buddy; name 
access$000 2(Lhaven/res/ui/rchan/RealmChannel;)Ljava/util/Map; java/lang/Integer valueOf (I)Ljava/lang/Integer; java/util/Map containsKey (Ljava/lang/Object;)Z get &(Ljava/lang/Object;)Ljava/lang/Object; equals haven/ChatUI fnd Foundry Lhaven/RichText$Foundry; format 9(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String; � haven/RichText$Parser Parser quote &(Ljava/lang/String;)Ljava/lang/String; java/awt/font/TextAttribute 
FOREGROUND Ljava/awt/font/TextAttribute; haven/RichText$Foundry render 8(Ljava/lang/String;I[Ljava/lang/Object;)Lhaven/RichText; 
haven/Text haven/ChatUI$Channel haven/RichText rchan.cjava ! ! "     # $    % &    ' $    ( )    * &    + ,    - .   / 0     1 2  3   ^     **+� *� *� *� *� *-� *� *� 	�    4   "     	   $        # ! ) "  % 5  3  7     и 
H*� � '*� g�� �*� � � � *� � N:� -� 	-� :� 1*� � *� � �  � *� � *� � �  � :� :*� � *� � � @*� � YSY*� S� � *� � Y� SY*� 	S� � *� *� �    6    � � ( 7 82� < 4   :    &  '  ( - ) 0 * 9 + ? , Z - r . w / { 0 � 1 � 2 � 5  9 :  3         *� � �    4       9  ; <  3   @     *� � *� �  �*� �  �    6     4       =  >  @ = @  3        *� �    4         A    � ?   2  ! O >  o _ q	 " o r	 T R s  h � � 	 d � � 	code   haven.res.ui.rchan.RealmChannel$UserError ����   4 
  
     <init> ((Ljava/lang/String;[Ljava/lang/Object;)V Code LineNumberTable 
SourceFile RealmChannel.java       )haven/res/ui/rchan/RealmChannel$UserError 	UserError InnerClasses java/lang/Exception java/lang/String format 9(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String; (Ljava/lang/String;)V haven/res/ui/rchan/RealmChannel rchan.cjava !        �       &     
*+,� � �       
    R 	 S  	        
     	code �  haven.res.ui.rchan.RealmChannel ����   46	  �
 Y � �
  � � �
  �	  � � � � � � � � � � �
  �
  �
  �
  �
  � � � � � � � Q� 	:� $� 
  �
 < � � � � � � �
 " �
  � �	  �
 < � � � �
  �
  � � �
 " �	  �
  � � �
  �	 S �
  �
 � �
  �
 Y � � � �
  �
 = �
  � � �
 < �
  �
  �	  �
  � � �
 H � � �
 Y �	  � � � �	 O �
 O � � �
 S �
 O �	 O � �
 � � � 	UserError InnerClasses PNamedMessage pnames Ljava/util/Map; 	Signature 6Ljava/util/Map<Ljava/lang/Integer;Ljava/lang/String;>; wcol Ljava/awt/Color; icon Lhaven/Indir; Lhaven/Indir<Lhaven/Resource;>; <init> (Ljava/lang/String;)V Code LineNumberTable mkwidget -(Lhaven/UI;[Ljava/lang/Object;)Lhaven/Widget; 	msgbyname C(Ljava/lang/String;)Lhaven/res/ui/rchan/RealmChannel$PNamedMessage; StackMapTable � parsedur (Ljava/lang/String;)I � cmd ([Ljava/lang/String;)V � � � send uimsg ((Ljava/lang/String;[Ljava/lang/Object;)V � Image ()Lhaven/Resource$Image; 
access$000 2(Lhaven/res/ui/rchan/RealmChannel;)Ljava/util/Map; <clinit> ()V 
SourceFile RealmChannel.java ] ^ f � java/util/HashMap f � java/lang/String haven/res/ui/rchan/RealmChannel f g � � � � � � � � � � � � � haven/ChatUI$Channel$Message Channel Message -haven/res/ui/rchan/RealmChannel$PNamedMessage � � � � � � � � � � s m h d w M � � � q rename ban unban )haven/res/ui/rchan/RealmChannel$UserError usage: rename NAME NEW-NAME java/lang/Object f z l m %s: no such name �  usage: ban NAME [DURATION] p q z usage: unban NAME %s: no such command a b	
 java/lang/Exception 	Error: %s b s t x g msg java/lang/Integer  haven/ChatUI$MultiChat$MyMessage 	MultiChat 	MyMessage � f	 � � f  err "haven/ChatUI$Channel$SimpleMessage SimpleMessage f enter leave y z c d  � haven/Resource!"#& haven/Resource$Image java/awt/Color f'()*, gfx/hud/chat/rlm-p-.12 haven/ChatUI$MultiChat java/util/ListIterator (ZLjava/lang/String;I)V msgs Ljava/util/List; java/util/List size ()I listIterator (I)Ljava/util/ListIterator; hasPrevious ()Z previous ()Ljava/lang/Object; haven/ChatUI$Channel 
access$100 C(Lhaven/res/ui/rchan/RealmChannel$PNamedMessage;)Ljava/lang/String; equals (Ljava/lang/Object;)Z length 	substring (I)Ljava/lang/String; hashCode (II)Ljava/lang/String; parseInt from I valueOf (I)Ljava/lang/Integer; java/util/Map put 8(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object; wdgmsg 
getMessage ()Ljava/lang/String; append %(Ljava/lang/String;Ljava/awt/Color;)V format 9(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String; RED charAt (I)C haven/Utils 
splitwords '(Ljava/lang/String;)[Ljava/lang/String; iw .(Lhaven/ChatUI$MultiChat;Ljava/lang/String;I)V !(Lhaven/ChatUI$Channel$Message;)V containsKey intValue 	fromcolor (I)Ljava/awt/Color; H(Lhaven/res/ui/rchan/RealmChannel;ILjava/lang/String;Ljava/awt/Color;I)V urgency notify "(Lhaven/ChatUI$Channel$Message;I)V &(Ljava/lang/String;Ljava/awt/Color;I)V haven/Indir get imgc Ljava/lang/Class; layer3 Layer )(Ljava/lang/Class;)Lhaven/Resource$Layer; (III)V classres #(Ljava/lang/Class;)Lhaven/Resource; pool Pool Lhaven/Resource$Pool; haven/Resource$Pool load4 Named +(Ljava/lang/String;I)Lhaven/Resource$Named; haven/ChatUI haven/Resource$Layer haven/Resource$Named rchan.cjava !  Y     ] ^  _    `  a b    c d  _    e 
  f g  h   3     *+� *� Y� � �    i         
   	 j k  h   ,     +2� M� Y,� �    i   
        l m  h   �     O*� *� � 	 � 
 M,�  � 4,�  � N-� �  -� :� � � +� � �����    n    �  o6�  i   "    E  F & G - H 3 I G J J L M M 	 p q  h  t    **� d� M>,� �     �      M   �   d   e   h   W   m   I   s   ;   w   s,� � K>� F,� � =>� 8,� � />� *,� � !>� ,� � >� ,� � >�    J          &   +   1   8   >   D<� $<<� <� <� <� <� <� <� **� d� K*� h�    n   $ � L  r
&�   r   i   2    X � Z � \ � ^ � ` � b � d � f � h � i � k � m  s t  h  �    �+2M>,� �    I   �K7>   " |   0�:�   >,� � !>� , � � >� ,!� � >�     !             j   �+�� � "Y#� $� %�*+2� &:� � "Y'� $Y+2S� %�*� � (� )+2� * W� �+�� � "Y+� $� %�*+2� &:� � "Y'� $Y+2S� %�6+�� +2� ,6* � $Y� (� )SY� )S� -� e+�� � "Y.� $� %�*+2� &:� � "Y'� $Y+2S� %�*!� $Y� (� )S� -� � "Y/� $Y+2S� %�� 'M*,� 0� 1� 2� M*4� $Y,S� 5� 6� 2�   �� "  �� 3  n   ; � , r
� ! u� � ! u� � � ! u� � B vN w i   � !   s p u v v � w � x � y � z � { � ~ �  � � � � � � � � � � � � �$ �' �- �; �D �I �] �r �u �� �� �� �� �� �� �� �  x g  h   l     1+� � '+� 7/� +� � 8M,� ,�� *,� 9� *+� :�    n    ( i       �  �  � # � ( � + � 0 � � y z  h  i     �+;� �,2� <N,2� ::,�� ,2� :-� *� =Y**� >� ?� @� U� *� -� A � *� -� * W� Y*-� B*-� B� C*� >� D:*� @*� E� **� E� F� I+G� +,2� N� HY-� 1*� >� I:*� @*� F� +J� � +K� � 	*+,� L�    n    	� & { r r� 2- i   ^    �  �  �  �  �  � & � * � ? � Q � ^ � z � � � � � � � � � � � � � � � � � � � � � � �  c }  h   -     � M� N � O� P� Q� R�    i       � ~   h        *� �    i       	  � �  h   ?      #� SY � �� T� 1� U� VW� X� M�    i   
    p  �  �   5 [   Z  "  Z 	   \  R O |  � � �	  � �	 Y � � 	 = Y �  H � � 	$ O% � O+ 	/ O0	codeentry '   wdg haven.res.ui.rchan.RealmChannel   