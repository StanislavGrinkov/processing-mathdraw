enum SystemState {
  DEFAULT,
  EDIT_PARAMS,
  EDIT_COLOR
}

abstract class DynamicSystem {
  protected boolean isSelected;
  protected String name;
  protected BaseColor currentColor;
  protected boolean isNegative = false;
  
  public abstract void drawMe(PGraphics pg);
  
  public abstract void processDefaultKeys();
  public abstract void processEditColorKeys();
  public abstract void processEditParamKeys();
  
  public abstract int drawHelpDefault(int y);
  public abstract int drawHelpEditParams(int y);
  public abstract int drawHelpEditColor(int y);
  
  public abstract RGroup getSvg();
  
  public abstract DynamicSystem clone();
  
  public void drawHelp(SystemState state) {
    textSize(14);
    fill(!isNegative ? 0 : 255);
    int y = 20;
    text("Press > w < to change background to black/white", 10, y); y += Constants.lineDrawStep;   
    if (state == SystemState.DEFAULT) {
      drawHelpDefault(y);
      return;
    }
    if (state == SystemState.EDIT_PARAMS) {
      text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
      drawHelpEditParams(y);
      return;
    }
    if (state == SystemState.EDIT_COLOR) {
      text("~~~~~~~~~~~~~~~~~~~~~~~~~~", 10, y); y += Constants.lineDrawStep;
      drawHelpEditColor(y);
      return;
    }
  };
  
  public void processKeys(SystemState state) {
    switch(key) {
      case 'w':
        isNegative = !isNegative;
        return;
    }
    if (state == SystemState.DEFAULT) {
      processDefaultKeys();
      return;
    }
    if (state == SystemState.EDIT_PARAMS) {
      processEditParamKeys();
      return;
    }
    if (state == SystemState.EDIT_COLOR) {
      processEditColorKeys();
      return;
    }
  };

  protected String getFileName(String prefix, String ext) {
    int y = year();
    String m = nf(month(), 2);
    String d = nf(day(), 2);
    String h = nf(hour(), 2);
    String mm = nf(minute(), 2);
    String s = nf(second(), 2);
    return String.format("%s-%d-%s-%sT%s%s%s.%s", prefix, y, m, d, h, mm, s, ext);
  }
  
  public void setSelected(boolean state) { isSelected = state;};
  public boolean getSelected() {return isSelected; };
}