abstract class StepFuncBase {
  protected float value;
  protected float min;
  protected float max;
  protected float step;
  protected float smallStep;
  
  public StepFuncBase(float initial, float min, float max, float step, float smallStep) {
    this.value = initial;
    this.min = min;
    this.max = max;
    this.step = step;
    this.smallStep = smallStep;
  }
  
  public abstract float next(float v);
  public abstract String description();
  public abstract StepFuncBase clone();
  
  public JSONObject getJSON() {
    JSONObject json = new JSONObject();
    json.setString(Constants.ObjectType, this.getClass().getName());
    json.setFloat(Constants.Value, value);
    json.setFloat(Constants.Min, min);
    json.setFloat(Constants.Max, max);
    json.setFloat(Constants.Step, step);
    json.setFloat(Constants.SmallStep, smallStep);
    return json;
  }
  
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
          value += smallStep;
        break;
      case 'F':
        if (value > min)
          value -= smallStep;
        break;
    }
  }
}

/**
*** Experimental sin step function
**/
class StepFuncSinStep extends StepFuncBase {
  
  public StepFuncSinStep(float init, float min, float max, float step, float smallStep) {
    super(init, min, max, step, smallStep);
  }
  
  @Override
  public float next(float v) {
    return v * -sin(radians(value));
  }
  
  @Override
  public String description() {
    return "Step function: some sin madness";
  }
  
  @Override
  public StepFuncBase clone() {
    return new StepFuncEqualStep(this.value, this.min, this.max, this.step, this.smallStep);
  }
}

/**
*** Non linear "value / divisor" step function.
**/
class StepFuncDivisor extends StepFuncBase {
  
  public StepFuncDivisor(float init, float min, float max, float step, float smallStep) {
    super(init, min, max, step, smallStep);
  }
  
  @Override
  public float next(float v) {
    return v / value;
  }
  
  @Override
  public String description() {
    return "Non linear step function h = h / divisor.";
  }
  
  @Override
  public StepFuncBase clone() {
    return new StepFuncDivisor(this.value, this.min, this.max, this.step, this.smallStep);
  }
}


/**
*** Linear equal step function "value - step"
**/
class StepFuncEqualStep extends StepFuncBase {
  
  public StepFuncEqualStep(float init, float min, float max, float step, float smallStep) {
    super(init, min, max, step, smallStep);
  }
  
  @Override
  public float next(float v) {
    return v - value;
  }
  
  @Override
  public String description() {
    return "Simple linear step function: h = h - step.";
  }
  
  @Override
  public StepFuncBase clone() {
    return new StepFuncEqualStep(this.value, this.min, this.max, this.step, this.smallStep);
  }
}