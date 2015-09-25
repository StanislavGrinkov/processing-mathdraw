class StepFuncSinStep extends StepFuncBase {
  
  public StepFuncSinStep(float init, float min, float max, float step) {
    super(init, min, max, step);
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
    return new StepFuncEqualStep(this.value, this.min, this.max, this.step);
  }
}