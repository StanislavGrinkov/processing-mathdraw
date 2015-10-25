import processing.opengl.*;
import com.jogamp.newt.event.KeyEvent;
import java.util.Collections;
import java.util.Comparator;

import geomerative.*;

ParametricSystemController controller = new ParametricSystemController();

void setup() {
  float v1 = map(0.25, 0.0, 1.0, 0.0, 0.3);
  float v2 = map(0.5, 0.0, 1.0, 0.3, 1.0);
  println("v1=" + v1);
  println("v2=" + v2);
  size(1000, 1000, P3D);
  smooth(8);
  hint(ENABLE_KEY_REPEAT);
  frameRate(50);
  RG.init(this);
  controller.setState(SystemState.EDIT_PARAMS);
}

void draw() {
  controller.drawMe(this.g);
}

void keyPressed() {
  controller.processKeys();
  redraw();
}