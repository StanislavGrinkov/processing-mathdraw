import java.awt.event.KeyEvent;

class ParametricSystemController extends DynamicSystem {
  
  ArrayList<DynamicSystem> dynamicSystems = new ArrayList<DynamicSystem>(); 
  DynamicSystem current = null;
  int index = 0;
  
  boolean emulateBallpen = false;
  
  SystemState state = SystemState.DEFAULT;
  
  public ParametricSystemController() {
    current = new ParametricCurve(this);
    dynamicSystems.add(current);
    index = 0;
  }
  
  @Override
  public RGroup getSvg(boolean emulateBallpen) {
    return null;
  }
  
  void drawHelperLines() {
    stroke(127);
    noFill();
    //rect(100, 1, 800, 999); // 8x10
    rect(1, 100, 999, 800); // 10x8
    
    stroke(192);
    line(0, 500, 1000, 500);
    line(500, 0, 500, 1000);
    
    textSize(14);
    fill(0);
    text("10x8", 960, 895);
    //text("8x10", 860, 995);
    noFill();
  }
  
  int drawDynamicSystemsCount(int y) {
    textSize(14);
    String c = "[ ";
    String s = "  ";
    for (int i =0; i < dynamicSystems.size(); ++i) {
      c += i != index ? "*" : "_";
      s += i == index ? "V" : "_";
    }
    c += " ]";
    fill(0);
    text(c, 10, y);
    fill(#ff0000);
    text(s, 10, y); y += Constants.lineDrawStep;
    fill(0);
    return y;
  }

  public DynamicSystem clone() {
    return null;
  }
  
  @Override
  public void drawMe(PGraphics pg) {
    pg.background(255);
  
    drawHelperLines();
    pg.pushMatrix();
    for (DynamicSystem curve: dynamicSystems) {
      curve.drawMe(pg);
    }
    pg.popMatrix();
    drawHelp(state);
  }
  
  public void processKeys() {
    this.processKeys(state);
  }

  
  @Override
  public void processDefaultKeys() {
    switch (key) {
      case 's':
        PGraphics pg = createGraphics(1000, 1000, P3D, null);
        pg.beginDraw();
        pg.smooth(8);
        pg.background(255);
        for (DynamicSystem curve: dynamicSystems) {
          curve.drawMe(pg);
        }
        pg.endDraw();
        pg.save("output/"+getFileName("preview", "png"));
        
        RSVG svg = new RSVG();
        RGroup group = new RGroup();
        for (DynamicSystem curve: dynamicSystems) {
          group.addElement(curve.getSvg(emulateBallpen));
        }
        svg.saveGroup("output/"+getFileName("vector", "svg"), group);
        break;
      case 'b':
        emulateBallpen = !emulateBallpen;
        break;
      case 'e':
        state = SystemState.EDIT_PARAMS;
        current.setSelected(true);
        break;
    }
  }
  
  public void setState(SystemState state) {
    this.state = state;
    redraw();
  }
  
  @Override
  public void processEditColorKeys() {
    current.processEditColorKeys();
  }
  
  @Override
  public void processEditParamKeys() {
    switch (key) {
      case 'p':
        current.setSelected(!current.getSelected());
        return;
      case 'c':
        current.setSelected(false);
        current = current.clone();
        dynamicSystems.add(current);
        index = dynamicSystems.size() - 1;
        current.setSelected(true);
        return;
    }
    current.setSelected(false);
    switch (keyCode) {
      case 0x1a: // insert
        current = new ParametricCurve(this);
        dynamicSystems.add(current);
        index = dynamicSystems.size() - 1;
        break;
      case 0x93: // delete
        if (dynamicSystems.size() == 1)
          break;
        dynamicSystems.remove(index);
        if (index > dynamicSystems.size() - 1)
          --index;
        current = dynamicSystems.get(index);
        break;
      case KeyEvent.VK_CLOSE_BRACKET:
        ++index;
        if (index > dynamicSystems.size() - 1)
          index = 0;
        current = dynamicSystems.get(index);
        break;
      case KeyEvent.VK_OPEN_BRACKET:
        --index;
        if (index < 0)
          index = dynamicSystems.size() - 1;
        current = dynamicSystems.get(index);
        break;
      case KeyEvent.VK_BACK_SPACE:
        state = SystemState.DEFAULT;
        current.setSelected(false);
        return;
    }
    current.setSelected(true);
    
    current.processEditParamKeys();
  }
  
  @Override
  public int drawHelpDefault(int y) {
    textSize(14);
    fill(0);
    text("Press > e < to enter param edit mode", 10, y); y += Constants.lineDrawStep;
    text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
    text("Press > s < to  save SVG and render preview on 1000x1000 canvas", 10, y); y += Constants.lineDrawStep;
    
    text("Press > b < to " + (emulateBallpen ? "Disable" : "Enable") + " ballpen emulation while render to svg (warn this will double all curves)", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public int drawHelpEditParams(int y) {
    y = drawDynamicSystemsCount(y);
    y = current.drawHelpEditParams(y);
    text("Press > c < to clone current DynamicSystem", 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  @Override
  public int drawHelpEditColor(int y) {
    current.drawHelpEditColor(y);
    return y;
  }
}