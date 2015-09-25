abstract class StepFuncBase {
  protected float value;
  protected float min;
  protected float max;
  protected float step;
  protected float halfStep;
  
  public StepFuncBase(float initial, float min, float max, float step) {
    this.value = initial;
    this.min = min;
    this.max = max;
    this.step = step;
    this.halfStep = step / 2;
  }
  
  public abstract float next(float v);
  public abstract String description();
  public abstract StepFuncBase clone();
  
  public int drawHelp(int y) {
    text(description(), 10, y); y += Constants.lineDrawStep;
    text(String.format("step value = %f [%f, %f] (+d,-D) (+f, -F)", value, min, max), 10, y); y += Constants.lineDrawStep;
    return y;
  }
  
  public void processKeys() {
    switch(key) {
      case 'd':
        if (value < max)
          value += step;
        break;
      case 'D':
        if (value > min)
          value -= step;
        break;
      case 'f':
        if (value < max)
          value += halfStep;
        break;
      case 'F':
        if (value > min)
          value -= halfStep;
        break;
    }
  }
  
}