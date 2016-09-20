// Map controller with Midi
import java.util.HashMap;
import java.util.Map;
import controlP5.*;
import javax.sound.midi.MidiDevice;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Receiver;
import javax.sound.midi.Transmitter;

ControlP5 cp5;
MidiSimple  midi;
int theIndex;
Map<String, String> midimapper = new HashMap<String, String>();

void setup() {

  size( 600, 400 );
  
  cp5 = new ControlP5( this );

  cp5.begin(cp5.addTab("a"));
  cp5.addSlider("a-1").setPosition(20, 120).setSize(200, 20)
      .setRange(0,255);//.setValue(200);

  cp5.addSlider("a-2").setPosition(20, 160).setSize(200, 20)
      .setRange(0,255);//.setValue(200);

  cp5.addSlider("a-3").setPosition(20, 200).setSize(200, 20)
      .setRange(0,255);//.setValue(200);
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
  midimapper.put( ref( device, i ), "a-1" );
  }
  popMatrix();
  pushMatrix();
  for (int i =0; i < 127; i ++){
  midimapper.put( ref( device, i ), "a-2" );
  }
  popMatrix();
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
                c.setColorBackground( 0xff08a2cf );
              } else {
                c.setColorBackground( 0xff003652 );
              }
            } else if ( c instanceof Bang ) {
              if ( b[ 2 ] > 0 ) {
                c.setValue( c.getValue( ) );
                c.setColorForeground( 0xff08a2cf );
              } else {
                c.setColorForeground( 0xff00698c );
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
  float s1 = cp5.getController("a-1").getValue();
  float s2 = cp5.getController("a-2").getValue();
  float s3 = cp5.getController("a-3").getValue();
  background( s1 + theIndex, s2, s3 );
}