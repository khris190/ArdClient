package haven.res.ui.inspect;

import haven.Coord;
import haven.Coord2d;
import haven.GameUI;
import haven.Gob;
import haven.GobIcon;
import haven.MCache;
import haven.MapView;
import haven.Resource;
import haven.UI;
import haven.Widget;

public class LocalInspect extends Widget {
    public MapView mv;
    public Hover last = null, cur = null;

    public static Widget mkwidget(UI ui, Object... args) {
        return (new LocalInspect());
    }

    protected void added() {
        super.added();
        mv = getparent(GameUI.class).map;
        move(Coord.z);
        resize(parent.sz);
    }

    public void destroy() {
        super.destroy();
    }

    public class Hover extends MapView.Hittest {
        public volatile boolean done = false;
        public Coord2d mc;
        public MapView.ClickInfo inf;
        public Gob ob;
        public Object tip;

        public Hover(Coord c) {
            mv.super(c);
        }

        @Override
        protected void hit(final Coord pc, final Coord2d mc, final MapView.ClickInfo inf) {
            this.mc = mc;
            this.inf = inf;
            this.done = true;
            if (inf != null) {
                for (Object o : inf.array()) {
                    if (o instanceof Gob) {
                        ob = (Gob) o;
                        break;
                    }
                }
            }
        }

        protected void nohit(Coord pc) {
            done = true;
        }

        public Object tip() {
            if (ob != null) {
                GobIcon icon = ob.getattr(GobIcon.class);
                if (icon != null) {
                    Resource.Tooltip name = icon.res.get().layer(Resource.tooltip);
                    if (name != null)
                        return (name.t);
                }
            }
            if (mc != null) {
                int tid = ui.sess.glob.map.gettile(mc.floor(MCache.tilesz));
                Resource tile = ui.sess.glob.map.tilesetr(tid);
                Resource.Tooltip name = tile.layer(Resource.tooltip);
                if (name != null)
                    return (name.t);
            }
            return (null);
        }
    }

    public boolean active() {
        return (true);
    }

    public void tick(double dt) {
        super.tick(dt);
        if ((cur != null) && cur.done) {
            last = cur;
            cur = null;
        }
        if (active()) {
            if (cur == null) {
                Coord mvc = mv.rootxlate(ui.mc);
                if (mv.area().contains(mvc)) {
                    cur = new Hover(mvc);
                    mv.delay(cur);
                }
            }
        } else {
            last = null;
        }
    }

    public Object tooltip(Coord c, Widget prev) {
        if (active()) {
            if (last != null)
                return (last.tip());
        }
        return (super.tooltip(c, prev));
    }
}