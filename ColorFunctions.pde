abstract class BaseColor {
  public abstract color getColor(float t);
  public abstract void processKeys();
  public abstract int drawHelp(int y);
  public abstract BaseColor clone();
}


/**
*** Two color gradient color function
**/
class TwoColorGradient extends BaseColor
{
	public final class ColorPair {
	  private color start;
	  private color end;
	  public ColorPair(color start, color end) {
		this.start = start;
		this.end = end;
	  }
	  public void setStart(int r, int g, int b) {
		start = color(r, g, b);
	  }
	  public void setEnd(int r, int g, int b) {
		end = color(r, g, b);
	  }
	  public color getStart() {
		return start;
	  }
	  public color getEnd() {
		return end;
	  }
	  
	  public color getAt(float t) {
		return lerpColor(start, end, t);
	  }
	}

  ColorPair[] presets = {
    new ColorPair(#00DD00, #DD0000)
  };
  ColorPair current = presets[0];
  
  @Override
  public color getColor(float t) {
    return current.getAt(t);
  }
  
  @Override
  public void processKeys() {
    println("Gradient color->" + key);
  }
  
  @Override
  public int drawHelp(int y) {
    return y;
  }
  
  @Override
  public BaseColor clone() {
    return new TwoColorGradient();
  }
}



/**
*** Simple solid color function
**/
class SolidColor extends BaseColor {
  
  color[] presets = {
    #DD0000,
    #00DD00,
    #0000DD,
    #2CCE00,
    #FFF364
  };
  int presetIndex = 0;
  
  int r = 221;
  int g = 0;
  int b = 0;
  
  color solid = presets[0];
  int d = 16;
  
    @Override
  public BaseColor clone() {
    SolidColor c =  new SolidColor();
    c.r = this.r;
    c.g = this.g;
    c.b = this.b;
    c.d = this.d;
    c.solid = this.solid;
    c.presetIndex = this.presetIndex;
    return c;
  }
  
  @Override
  public color getColor(float t) {
    return solid;
  }
  
  @Override
  public void processKeys() {
    println("solid colors->" + key);
    switch (key) {
      case 'r':
        r += d;
        r = r > 255 ? 255 : r;
        break;
      case 'R':
        r -= d;
        r = r < 0 ? 0 : r;
        break;
      case 'g':
        g += d;
        g = g > 255 ? 255 : g;
        break;
      case 'G':
        g -= d;
        g = g < 0 ? 0 : g;
        break;
      case 'b':
        b += d;
        b = b > 255 ? 255 : b;
        break;
      case 'B':
        b -= d;
        b = b < 0 ? 0 : b;
        break;
      case 'd':
        d = d * 2;
        d = d > 64 ? 64 : d;
        break;
      case 'D':
        d = d / 2;
        d = d < 2 ? 1 : d;
        break;
      case ']':
        ++presetIndex;
        if (presetIndex > presets.length - 1)
          presetIndex = 0;
        solid = presets[presetIndex];
        r = solid >> 16 & 0xFF;
        g = solid >> 8 & 0xFF;
        b = solid & 0xFF;
        break;
      case '[':
        --presetIndex;
        if (presetIndex < 0)
          presetIndex = presets.length - 1;
        solid = presets[presetIndex];
        r = solid >> 16 & 0xFF;
        g = solid >> 8 & 0xFF;
        b = solid & 0xFF;
        break;
    }
    solid = color(r, g, b);
  }
  
  @Override
  public int drawHelp(int y) {
    text("Red: " + r + " (+r; -R)", 10, y); y += Constants.lineDrawStep;
    text("Green: " + g + " (+g; -G)", 10, y); y += Constants.lineDrawStep;
    text("Blue: " + b + " (+b; -B)", 10, y); y += Constants.lineDrawStep;
    text("Delta: " + d + " (+d; -D)", 10, y); y += Constants.lineDrawStep;   
    text("Current: #" + hex(solid, 6), 10, y); y += Constants.lineDrawStep;
    fill(solid);
    rect(10, y - Constants.lineDrawStep + 2, 50, 15);
    fill(0);
    y += Constants.lineDrawStep + 5;
    text("use [ and ] to select preset color ", 10, y); y += Constants.lineDrawStep;
    drawPresetColors(y - Constants.lineDrawStep + 2); y += Constants.lineDrawStep;
    return y;
  }
  
  public void drawPresetColors(int y) {
    int w = 20;
    for (int i = 0; i < presets.length; ++i) {
      color c = presets[i];
      fill(c);
      noStroke();
      if (i == presetIndex) {
        stroke(0);
        strokeWeight(1.5f);
      }
      rect(10 + w * i, y, w, 15);
      fill(0);
    }
  }
}
