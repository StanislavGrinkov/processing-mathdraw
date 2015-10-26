import processing.opengl.*;
import com.jogamp.newt.event.KeyEvent;
import java.util.Collections;
import java.util.Comparator;

import geomerative.*;

ParametricSystemController controller = new ParametricSystemController();

void setup() {
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

public void keyPressed() {
  controller.processKeys();
  redraw();
}