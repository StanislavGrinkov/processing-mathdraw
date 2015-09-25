import geomerative.*;

class ParametricCurve extends DynamicSystem {
  final class PathPoint {
    public float x;
    public float y;
    
    public PathPoint(float x, float y) {
      this.x = x;
      this.y = y;
    }
  }

  ParametricSystemController controller;
  
  ArrayList<PathPoint> pathPoints = new ArrayList<PathPoint>();
  StepFuncBase[] stepFunctions = {
    new StepFuncEqualStep(0.1, -5, 5, 0.01),
    new StepFuncDivisor(1.1, 1.01, 2.1, 0.01),
    //new StepFuncSinStep(0, -180, 180, 2),
  };
  int stepFuncIndex = 0;
  StepFuncBase currentStepFunc = stepFunctions[stepFuncIndex];
  
  boolean isEpitrochoid = false;
  
  float a = 5;
  float b = 4.5;
  float h = 5;
  float zoom = 50;
  int rev = 9;
  float rotationAngle = 0;
  int iterations = 10; 
  float iterationAngle = 0;
  float center_x = 0;
  float center_y = 0;
  
  boolean applyStepFuncToH = true;
  boolean applyStepFuncToZoom = false;
  
  public ParametricCurve(ParametricSystemController controller) {
    name = "PC-" + Math.round(Math.random()*5000);
    this.controller = controller;
  }
  
  @Override
  public DynamicSystem clone() {
    ParametricCurve pc = new ParametricCurve(this.controller);
    pc.a = this.a;
    pc.b = this.b;
    pc.h = this.h;
    pc.zoom = this.zoom;
    pc.rev = this.rev;
    pc.rotationAngle = this.rotationAngle;
    pc.iterationAngle = this.iterationAngle;
    pc.iterations = this.iterations;
    pc.center_x = this.center_x;
    pc.center_y = this.center_y;
    pc.applyStepFuncToH = this.applyStepFuncToH;
    pc.applyStepFuncToZoom = this.applyStepFuncToZoom;
    pc.isEpitrochoid = this.isEpitrochoid;
    for (int i = 0; i < stepFunctions.length; ++i) {
      pc.stepFunctions[i] = this.stepFunctions[i].clone();
    }
    pc.stepFuncIndex = this.stepFuncIndex;
    pc.currentStepFunc = pc.stepFunctions[pc.stepFuncIndex];
    return pc;
  }
  
  private void calculateHypotrochoidPath(float h, float factor) {
    float a_ = a * factor;
    float b_ = b * factor;
    float h_ = h * factor;
    float r = a_ - b_;
    float rb = r / b_;
    pathPoints.clear();
    for (int t = 0; t < rev*360 + 2; ++t) {
      float rt = radians(t);
      float x = (r * cos(rt) + h_ * cos(rb * rt));
      float y = (r * sin(rt) - h_ * sin(rb * rt));
      pathPoints.add(new PathPoint(x, y));
    }    
  }
  
  private void calculateEpitrochoidPath(float h, float factor) {
    float a_ = a * factor;
    float b_ = b * factor;
    float h_ = h * factor;
    float r = a_ - b_;
    float rb = r / b_;
    pathPoints.clear();
    for (int t = 0; t < rev*360 + 2; ++t) {
      float rt = radians(t);
      float x = (r * cos(rt) - h_ * cos(rb * rt));
      float y = (r * sin(rt) - h_ * sin(rb * rt));
      pathPoints.add(new PathPoint(x, y));
    }    
  }

  @Override
  public RGroup getSvg(boolean emulateBallpen) {
    colorMode(RGB, 255);
    RGroup group = new RGroup();
    float h_ = h;
    float zoom_ = zoom;
    for (int i = 0; i < iterations; ++i) {
      if (isEpitrochoid)
        calculateEpitrochoidPath(h_, zoom_);
      else
        calculateHypotrochoidPath(h_, zoom_);
      
      PathPoint p = pathPoints.get(0);
      RPath path = new RPath(p.x, p.y);
      for (int t = 1; t < pathPoints.size(); ++t) {
        p = pathPoints.get(t);
        path.addLineTo(p.x, p.y);
      }
      
      if (applyStepFuncToZoom)
        zoom_ = currentStepFunc.next(zoom_);        
      if (applyStepFuncToH)
        h_ = currentStepFunc.next(h_);
        
      RShape shape = path.toShape();
      shape.setStroke(colorizer.getColor(1));
      shape.setFill(false);
      shape.translate(center_x*i, center_y*i);
      shape.rotate(radians(iterationAngle * i), shape.getCenter());
      group.addElement(shape);
      if (emulateBallpen) {
        // get hsv.
        colorMode(RGB, 255);
        color c = colorizer.getColor(1);
        float hue = hue(c);
        float sat = saturation(c);
        float br = brightness(c); br = 220;
        
        colorMode(HSB, 255);
        color cLight = color(hue, sat, br);
        
        shape = path.toShape();
        shape.setStroke(cLight);
        shape.setStrokeWeight(0.5f);
        shape.setFill(false);
        shape.translate(center_x*i, center_y*i);
        shape.rotate(radians(iterationAngle * i), shape.getCenter());
        group.addElement(shape);
      }
    }
    group.rotate(radians(rotationAngle), group.getCenter());
    return group;
  }
  
  @Override
  public void drawMe(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(width / 2, height / 2);
    pg.rotate(radians(rotationAngle));
    pg.noFill();

    pg.strokeWeight(1);
    float h_ = h;
    float zoom_ = zoom;

    color vertexColor = isSelected ? #0000FF : colorizer.getColor(0); //float lerpStep = 1.0 / pathPoints.size(); //colorizer.getColor(t*lerpStep);
    
    for (int i = 0; i < iterations; ++i) {
      if (isEpitrochoid)
        calculateEpitrochoidPath(h_, zoom_);
      else
        calculateHypotrochoidPath(h_, zoom_);
      pg.beginShape();
      for (int t = 0; t < pathPoints.size(); ++t) {
        PathPoint p = pathPoints.get(t);
        
        pg.stroke(vertexColor);
        pg.vertex(p.x, p.y);
      }
      pg.endShape();    
      
      if (applyStepFuncToZoom)
        zoom_ = currentStepFunc.next(zoom_);        
      if (applyStepFuncToH)
        h_ = currentStepFunc.next(h_);
      pg.rotate(radians(iterationAngle));
      pg.translate(center_x, center_y);
    }
    pg.popMatrix();
  }
  
  @Override
  public void processDefaultKeys() {
  }
  
  @Override
  public void processEditColorKeys() {
    colorizer.processKeys();
    switch (keyCode) {
      case KeyEvent.VK_BACK_SPACE:
        controller.setState(SystemState.EDIT_PARAMS);
        this.isSelected = true;
        break;
    }
  }
  
  @Override
  public void processEditParamKeys() {
    float r_step = 0.5;
    float h_step = 0.5;
    float zoom_step = 1;
    float d_moveStep = 0.5;
    float stepAngle = 0.5;
    currentStepFunc.processKeys();
    
    if (key == CODED) {
      switch (keyCode) {
        case UP:
          center_y -= d_moveStep;
          break;
        case DOWN:
          center_y += d_moveStep;
          break;
        case LEFT:
          center_x -= d_moveStep;
          break;
        case RIGHT:
          center_x += d_moveStep;
          break;
      }
      return;
    }
    switch (key) {
      case 'a':
        a += r_step;
        break;
      case 'A':
        a -= r_step;
        break;
      case 'b':
        b += r_step;
        break;
      case 'B':
        b -= r_step;
        break;
      case 'h':
        h += h_step;
        break;
      case 'H':
        h -= h_step;
        break;
      case 'r':
        ++rev;
        break;
      case 'R':
        if (rev > 1)
          --rev;
        break;
      case 'z':
        zoom += zoom_step;
        break;
      case 'Z':
        zoom -= zoom_step;
        break;
      case 'g':
        ++rotationAngle;
        break;
      case 'G':
        --rotationAngle;
        break;
      case 'j':
        iterationAngle += stepAngle;
        break;
      case 'J':
        iterationAngle -= stepAngle;
        break;
      case 'i':
        ++iterations;
        break;
      case 'I':
      if (iterations > 1)
          --iterations;
        break;
      case 'e':
        controller.setState(SystemState.EDIT_COLOR);
        this.isSelected = false;
        break;
      case ',':
        --stepFuncIndex;
        if (stepFuncIndex < 0)
          stepFuncIndex = stepFunctions.length - 1;
        currentStepFunc = stepFunctions[stepFuncIndex];
        break;
      case '.':
        ++stepFuncIndex;
        if (stepFuncIndex > stepFunctions.length - 1)
          stepFuncIndex = 0;
        currentStepFunc = stepFunctions[stepFuncIndex];
        break;
      case 'n':
        applyStepFuncToH = !applyStepFuncToH;
        break;
      case 'm':
        applyStepFuncToZoom = !applyStepFuncToZoom;
        break;
      case 't':
        isEpitrochoid = !isEpitrochoid;
        break;
        
    }
  }
  
  @Override
  public int drawHelpDefault(int y) {
    return y;
  }
  
  @Override
  public int drawHelpEditParams(int y) {
    text("use [ and ] to navigate between dynamic systems.", 10, y); y += Constants.lineDrawStep;
    text("name = " + name, 10, y); y += Constants.lineDrawStep;
    text((isEpitrochoid ? "Epitrochoid " : "Hypotrochoid") + " pattern (t to toggle)", 10, y); y += Constants.lineDrawStep;
    text("a = " + a + "  (+a, -A)", 10, y); y += Constants.lineDrawStep;
    text("b = " + b + "  (+b, -B)", 10, y); y += Constants.lineDrawStep;
    text("h = " + h + "  (+h, -H)", 10, y); y += Constants.lineDrawStep;
    text("rv = " + rev + "  (+r, -R)", 10, y); y += Constants.lineDrawStep;
    text("zoom = " + zoom + "  (+z, -Z)", 10, y); y += Constants.lineDrawStep;
    text("rotation = " + rotationAngle + "  (+g,-G)", 10, y); y += Constants.lineDrawStep;
    text("iteartions = " + iterations + "  (+i,-I)", 10, y); y += Constants.lineDrawStep;
    text("iteartionAngle = " + iterationAngle + "  (+j,-J)", 10, y); y += Constants.lineDrawStep;
    text("center_point = " + center_x + ", " + center_y + "  (arrows)", 10, y); y += Constants.lineDrawStep;
    text("Apply StepFunc To H = " + applyStepFuncToH + "  (n to toggle)", 10, y); y += Constants.lineDrawStep;
    text("Apply StepFunc To Z = " + applyStepFuncToZoom + "  (m to toggle)", 10, y); y += Constants.lineDrawStep;
    y = currentStepFunc.drawHelp(y);
    text("use < and > to change step functions systems.", 10, y); y += Constants.lineDrawStep;
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > e < to enter color edit mode", 10, y); y += Constants.lineDrawStep;
    text("Press > backspace < to exit from Edit Parameters mode", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public int drawHelpEditColor(int y) {
    y = colorizer.drawHelp(y);
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > backspace < to exit from Edit Color mode", 10, y); y += Constants.lineDrawStep;
    return y;
  }
}