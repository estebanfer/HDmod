float4 LiquidHelper(float2 tex, float2 noise, float currentLiquidSample, Texture2D liquidTexture) {
  float4 WATER_COLOR = float4(1.0f, 0.0f, 0.0f, 0.5f);
  float4 LAVA_COLOR = float4(0.0f, 1.0f, 0.0f, 0.9f);
  float4 EGGJUICE_COLOR = float4(0.0f, 1.0f, 0.0f, 0.9f);//0.0f, 0.0f, 1.0f, 0.5f);

	float alpha = saturate((1.f / (LIQUID_END_CUTOFF - LIQUID_START_CUTOFF)) * currentLiquidSample - (LIQUID_START_CUTOFF / (LIQUID_END_CUTOFF - LIQUID_START_CUTOFF)));
	if (alpha == 0.f) {
		// Air
		return float4(0.f, 0.f, 0.f, 0.f);
	}
	float4 liquidSample = liquidTexture.Sample(smoothClampingSamplerState, float2(1.f, 0.f));
  if(distance(liquidSample.rgb, float3(0.04705882352f, 0.69411764705f, 0.89803921568f)) < 0.1f) {
    //liquidSample = WATER_COLOR;
  } else if(distance(liquidSample.rgb, float3(1.0f, 0.56078431372, 0.0f)) < 0.1f) {
    //liquidSample = LAVA_COLOR;
  } else {
    liquidSample = EGGJUICE_COLOR;
  }
	float3 diffuseSample = pow(texture1.Sample(smoothClampingSamplerState, tex + alpha * noise * LIQUIDREFRACTION_NOISE).rgb, 1.f / GAMMA_CORRECTION);
	return float4(lerp(diffuseSample, liquidSample.rgb, liquidSample.a * alpha), 1.f);
}

/*LightOutput mainp_LiquidLava_PS(PixelInputType input) {
  float4 GLOW_COLOR = float4(1.0f, 0.0f, 0.5f, 1.0f);

  LightOutput output;
  float currentLiquidSample = texture0.Sample(smoothBorderSamplerState, input.tex).g;
  float4 liquidOutput = LiquidHelper(input.tex, float2(0.f, 0.f), currentLiquidSample, texture4);
  output.liquid = float4(pow(liquidOutput.rgb, GAMMA_CORRECTION), liquidOutput.a * GLOW_COLOR.a);
  output.emissive = float4(.4f * liquidOutput.a * GLOW_COLOR.a * GLOW_COLOR.rgb, liquidOutput.a * GLOW_COLOR.a);
  return output;
}
*/