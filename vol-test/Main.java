class LockClass{}
public class Main{

    public void prs2(String s, LockClass lc){
        try{
           synchronized(lc){
            System.out.println(s);
            Thread.sleep(1000);
            System.out.println("Completed "+s);
           }
        }catch(Exception e){}
    }
//    public synchronized void prs2(String s){
//        try{
//            System.out.println("prs2: "+s);
//            Thread.sleep(1000);
//            System.out.println("prs2 Completed "+s);
//        }catch(Exception e){}
//    }
    public static synchronized void printMsg(String s){
        try{
            Thread.sleep(1000);
            System.out.println(s);
            Thread.sleep(1000);
        }catch(Exception e){
            System.out.println("Thread error:"+e.getMessage());
        }
    }
    public static void main(String[] args){
        Main m = new Main();
        LockClass lc1 = new LockClass();
        LockClass lc2 = new LockClass();
        Thread t1 = new Thread(){
            public void run(){
                m.prs2("T1",lc1);
            }
        };

        Thread t2 = new Thread(){
            public void run(){
                m.prs2("T2",lc2);
            }
        };
        t1.start();
        t2.start();
        try{
            Thread.sleep(10000);
        }catch(InterruptedException ie){}
    }
}
