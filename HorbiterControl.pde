// 1 & 0 fucking cube matrix midi controlla 

//import peasy.*;
import hype.*;
import hype.extended.behavior.*;
import hype.extended.colorist.*;
import hype.extended.layout.*;
import hype.interfaces.*;
import hype.extended.behavior.HOrbiter3D;
import ddf.minim.Minim;
import ddf.minim.AudioInput;
import ddf.minim.analysis.*;
import java.util.HashMap;
import java.util.Map;
import controlP5.*;
import javax.sound.midi.MidiDevice;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Receiver;
import javax.sound.midi.Transmitter;

//PeasyCam      cam;
HDrawablePool pool;
HOrbiter3D    orb;
HTimer       timerPool;

Minim         minim;
AudioInput  myAudio;
//AudioPlayer   myAudio;
FFT           myAudioFFT;

ControlP5           cp5;
MidiSimple          midi;
int                 theIndex;
Map<String, String> midimapper = new HashMap<String, String>();


boolean       showVisualizer   = false;

int           myAudioRange     = 11;
int           myAudioMax       = 20;

float         myAudioAmp       = 40.0;
float         myAudioIndex     = 0.2;
float         myAudioIndexAmp  = myAudioIndex;
float         myAudioIndexStep = 0.35;
float[]       myAudioData      = new float[myAudioRange];

int           rR = 800;  
float         r  = 0.0;

final HColorPool colors = new HColorPool(#920F0E,#A71914,#FFFFFF,#FFFFFF,#BB2D1B,#D0432D,#A33520,#FFFFFF);

void setup() {
  size(640,800, P3D);
  //fullScreen(OPENGL);

  H.init(this).background(#000000).use3D(true).autoClear(false);
  smooth();

   minim   = new Minim(this);
   myAudio = minim.getLineIn(Minim.MONO);

  // myAudio = minim.loadFile("m.mp3");
  // myAudio.loop();

   myAudioFFT = new FFT(myAudio.bufferSize(), myAudio.sampleRate());
   myAudioFFT.linAverages(myAudioRange);

  pool = new HDrawablePool(rR);
  pool.autoAddToStage()
    .add(new HShape("1.svg").enableStyle(false).anchorAt(H.CENTER) )
    .add(new HShape("0.svg").enableStyle(false).anchorAt(H.CENTER) )

    .onCreate(new HCallback() {
      public void run(Object obj) {
          int i = pool.currentIndex();
        int ranIndex = (int)random(myAudioRange);

        HShape d = (HShape) obj;
        d
          .noStroke()
          .strokeCap(ROUND).strokeJoin(ROUND)
          .fill(colors.getColor(),225)
          .loc(  (int)random(-width/2,width/2) , (int)random(height), (int)random(-width/2,width/2) )
          .extras( new HBundle().num("i", ranIndex) )
          

           .obj("xo", new HOscillator()
              .target(d)
              .property(H.X)
              .relativeVal(d.x())
              .range(-(int)random(5,10), (int)random(5,10))
              .speed( random(.005,.2) )
              .freq(0)
              .currentStep(i)
            )

            .obj("ao", new HOscillator()
              .target(d)
              .property(H.ALPHA)
              .range(0,255)
              .speed( random(.3,.9) )
              .freq(1)
              .currentStep(i)
            )

            .obj("wo", new HOscillator()
              .target(d)
              .property(H.ROTATION)
              .range(-d.width(),d.width())
              .speed( random(.05,.2) )
              .freq(0)
              .currentStep(i)
            )

            .obj("ro", new HOscillator()
              .target(d)
              .property(H.ROTATION)
              .range(-180,180)
              .speed( random(.005,.05) )
              .freq(0)
              .currentStep(i)
            )
          ;
          
            new HRotate().target(d).speed( random(0.01,1.1) )
            ;
        }
      }
    )
    .onRequest(
      new HCallback() {
        public void run(Object obj) {
          HDrawable d = (HDrawable) obj;
          d.scale(1).alpha(0).loc((int)random(-width/2,-width/2),(int)random(height));

          HOscillator xo = (HOscillator) d.obj("xo"); xo.register();
          HOscillator ao = (HOscillator) d.obj("ao"); ao.register();
          HOscillator wo = (HOscillator) d.obj("wo"); wo.register();
          HOscillator ro = (HOscillator) d.obj("ro"); ro.register();
        }
      }
    )

    .onRelease(
      new HCallback() {
        public void run(Object obj) {
          HDrawable d = (HDrawable) obj;

          HOscillator xo = (HOscillator) d.obj("xo"); xo.unregister();
          HOscillator ao = (HOscillator) d.obj("ao"); ao.unregister();
          HOscillator wo = (HOscillator) d.obj("wo"); wo.unregister();
          HOscillator ro = (HOscillator) d.obj("ro"); ro.unregister();
        }
      }
    )
  ;

  new HTimer(40)
    .callback(
      new HCallback() {
        public void run(Object obj) {
          pool.request();
        }
      }
    )
  ;

   translate(-50000, 0, 0);


  cp5 = new ControlP5( this );

  cp5.begin(cp5.addTab("a"));
  cp5.addSlider("a-1").setPosition(-120, 120).setSize(200, 20)
      .setRange(0,255);//.setValue(200);

  cp5.addSlider("a-2").setPosition(-120, 160).setSize(200, 20)
      .setRange(0,255);//.setValue(200);

  cp5.addSlider("a-3").setPosition(-120, 200).setSize(200, 20)
      .setRange(0,25);//.setValue(200);
  cp5.addToggle("a-4").setPosition(280, 120).setSize(100, 20);
  cp5.addButton("a-5").setPosition(280, 160).setSize(100, 20);
  cp5.addBang("a-6").setPosition(280, 200).setSize(100, 20);
  cp5.end();
  
  cp5.begin(cp5.addTab("b"));
  cp5.addSlider("b-1").setPosition(20, 120).setSize(200, 20);
  cp5.addSlider("b-2").setPosition(20, 160).setSize(200, 20);
  cp5.addSlider("b-3").setPosition(20, 200).setSize(200, 20);
  cp5.end();
  
  final String device = "MIDI Mix";
  
  //midimapper.clear();
 
  pushMatrix();
  for (int i =0; i < 127; i ++){
  midimapper.put( ref( device, i ), "a-3" );
  }
  popMatrix();
  midimapper.put( ref( device, 32 ), "a-4" );
  midimapper.put( ref( device, 48 ), "a-5" );
  midimapper.put( ref( device, 64 ), "a-6" );

  midimapper.put( ref( device, 16 ), "b-1" );
  midimapper.put( ref( device, 17 ), "b-2" );
  midimapper.put( ref( device, 18 ), "b-3" );

  boolean DEBUG = true;

  if (DEBUG) {
    new MidiSimple( device );
  } 
   midi = new MidiSimple( device , new Receiver() {

      @Override public void send( MidiMessage msg, long timeStamp ) {

        byte[] b = msg.getMessage();

        if ( b[ 0 ] != -48 ) {

          Object index = ( midimapper.get( ref( device , b[ 2 ] ) ) );

          if ( index != null ) {

            Controller c = cp5.getController(index.toString());
            if (c instanceof Slider ) {  
              float min = c.getMin();
              float max = c.getMax();
              c.setValue(map(b[ 2 ], 0, 127, min, max) );

            }  else if ( c instanceof Button ) {
              if ( b[ 2 ] > 0 ) {
                c.setValue( c.getValue( ) );
                c.setColorBackground( #000000 );
              } else {
                c.setColorBackground( #000000 );
              }
            
            } else if ( c instanceof Bang ) {
              if ( b[ 2 ] > 0 ) {
                c.setValue( c.getValue( ) );
                c.setColorForeground( #000000 );
              } else {
                c.setColorForeground( #000000 );
              }
            
            } else if ( c instanceof Toggle ) {
              if ( b[ 2 ] > 0 ) {
                ( ( Toggle ) c ).toggle( );
              }
            }
          }
        }
      }

      @Override public void close( ) {
      }
    }
    );
}

String ref(String theDevice, int theIndex) {
  return theDevice+"-"+theIndex;
}

void draw() {
  //background(miColor);
  translate(width/2+0, height/2+-350 ,-width/4);
  myAudioFFT.forward(myAudio.mix);
  myAudioDataUpdate();

  pushMatrix();
  translate(-1908, -200, -548);
  fill(0,14); rect(-width/2, -height,width*5, height*5);
  popMatrix();

  pushMatrix();
  rotateY(r);

  float s1 = cp5.getController("a-1").getValue();
  float s2 = cp5.getController("a-2").getValue();
  float s3 = cp5.getController("a-3").getValue();

  for(HDrawable d : pool) {
    d.loc( d.x(), d.y() - random(0.07,s3) );

    if (d.y() < -40) {
      pool.release(d);
  r += 0.000;
    }
  }

  H.drawStage();
  popMatrix();

   for (HDrawable d : pool) {
     HBundle tempExtra = d.extras();
     int i = (int)tempExtra.num("i");
     int fftFillColor = (int)map(myAudioData[i], 0, myAudioMax, 0, 255);
     d.fill(colors.getColor(),fftFillColor);
   }
  if (showVisualizer) myAudioDataWidget();
}

void myAudioDataUpdate() {
  for (int i = 0; i < myAudioRange; ++i) {
    float tempIndexAvg = (myAudioFFT.getAvg(i) * myAudioAmp) * myAudioIndexAmp;
    float tempIndexCon = constrain(tempIndexAvg, 0, myAudioMax);
    myAudioData[i]     = tempIndexCon;
    myAudioIndexAmp+=myAudioIndexStep;
  }
  myAudioIndexAmp = myAudioIndex;
}

void myAudioDataWidget() {
  noLights();
  hint(DISABLE_DEPTH_TEST);
  noStroke(); fill(0,200); rect(0, height-112, width, 102);
  for (int i = 0; i < myAudioRange; ++i) {
    fill(#CCCCCC); rect(10 + (i*5), (height-myAudioData[i])-11, 4, myAudioData[i]);
  }
  hint(ENABLE_DEPTH_TEST);
}

void stop() {
  myAudio.close();
  minim.stop();  
  super.stop();
}
