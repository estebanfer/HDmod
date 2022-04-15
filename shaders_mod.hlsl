#define ACID_RGBA float4(.25f, 1.0f, .0f, .3f)

//For acid particles and effects
PixelProcessOutput mainp_Process_DeferredTextureColor_Transparent_PS(PixelProcessInput input) {
	float4 textureSample = texture0.Sample(smoothWrappingSamplerState, input.tex);
	if (textureSample.a == 0.f) {
		discard;
	}
	if(distance(input.color.rgb, float3(.7f, .05f, .32f)) < .3f) {
    	input.color = ACID_RGBA;
	}
	
	float4 outputColor = float4(input.color.rgb * textureSample.rgb, input.color.a * textureSample.a);

	PixelProcessOutput pixelProcessOutput;
	pixelProcessOutput.emissive = float4(0.f, 0.f, 0.f, outputColor.a);
	pixelProcessOutput.transparency = outputColor;

	return pixelProcessOutput;
}

LowPPixelProcessOutput mainp_lowP_Process_DeferredTextureColor_Transparent_PS(PixelProcessInput input) {
	float4 textureSample = texture0.Sample(smoothWrappingSamplerState, input.tex);
	if (textureSample.a == 0.f) {
		discard;
	}
	if(distance(input.color.rgb, float3(.7f, .05f, .32f)) < .3f) {
    	input.color = ACID_RGBA;
	}

	float4 outputColor = float4(input.color.rgb * textureSample.rgb, input.color.a * textureSample.a);

	LowPPixelProcessOutput pixelProcessOutput;
	pixelProcessOutput.diffuse = outputColor;

	return pixelProcessOutput;
}

//For acid
//It might seem that I know what I'm doing, but I have no idea about the glowing, just copied this from TemperatureHelper (Estebanfer)
float3 AcidHelper(float acidness) {
	// Only works for temperature <= 6500.0

	//orignal (lava)
	//float3 m0 = float3(0.0f,-1902.1955373783176f,-8257.7997278925690f);
	//float3 m1 = float3(0.0f, 1669.5803561666639f, 2575.2827530017594f);
	//float3 m2 = float3(1.0f, 1.3302673723350029f, 1.8993753891711275f);

	//Some colors swapped (blueish)
	//float3 m0 = float3(-8257.7997278925690f, 0.0f, -1902.1955373783176f);
	//float3 m1 = float3(2575.2827530017594f, 0.0f, 1669.5803561666639f);
	//float3 m2 = float3(1.8993753891711275f, 1.0f, 1.3302673723350029f);

	//SNF's favorite
	//replace the first line with #define ACID_RGBA float4(.0f, 1.0f, .0f, .43f)
	//float3 m0 = float3(-4128.899863946284f, -951.0977686891588f, -5079.997632635443f);
	//float3 m1 = float3(1287.6413765008797f, 834.790178083332f, 2122.431554584212f);
	//float3 m2 = float3(1.4496876945855637f, 1.1651336861675015f, 1.6148213807530651f);

	//most yellow
	//float3 m0 = float3(0.0f, -1426.64665303373828f, -6668.898680264006f);
	//float3 m1 = float3(0.0f, 1252.185267124998f, 2348.8571537929856f);
	//float3 m2 = float3(1.0f, 1.2477005292512522f, 1.7570983849620965f);

	//acid-bubble-like
	float3 m0 = float3(-2064.449931973142f, -1426.64665303373828f, -6668.898680264006f);
	float3 m1 = float3(643.8206882504398f, 1252.185267124998f, 2348.8571537929856f);
	float3 m2 = float3(1.2248438472927818f, 1.2477005292512522f, 1.7570983849620965f);
	return saturate(m0 / (acidness +  m1) + m2);
}

LiquidOutput mainp_LiquidEggplant_PS(PixelInputType input) {
	LiquidOutput output;

	float currentLiquidSample = texture0.Sample(smoothBorderSamplerState, input.tex).r;

	// Get final refracted position
	float2 noise = GetRefractionVector(input.tex, LIQUIDREFRACTION_TIMESTEP_MULTIPLIER, LIQUIDREFRACTION_NOISE, LIQUIDREFRACTION_THRESHOLD);

	float4 liquidOutput = LiquidHelperWater(input.tex, noise, currentLiquidSample, ACID_RGBA);
	output.liquid = pow(liquidOutput, GAMMA_CORRECTION);

	//copied from lava
	float sampleHotness = pow(currentLiquidSample, 4.f);
	float3 emissiveTint = AcidHelper(3000.f * sampleHotness);
	output.emissive = float4(.1f * liquidOutput.a * emissiveTint, liquidOutput.a);

	//Original emissive
	//output.emissive = float4(0.f, 0.f, 0.f, 0.f);

	return output;
}

float4 mainp_lowp_LiquidEggplant_PS(PixelInputType input) : SV_TARGET0 {
	float4 output;

	float currentLiquidSample = texture0.Sample(smoothBorderSamplerState, input.tex).r;

	// Get final refracted position
	float2 noise = GetRefractionVector(input.tex, LIQUIDREFRACTION_TIMESTEP_MULTIPLIER, LIQUIDREFRACTION_NOISE, LIQUIDREFRACTION_THRESHOLD);

	float4 liquidOutput = LiquidHelperWater(input.tex, noise, currentLiquidSample, ACID_RGBA);
	output = pow(liquidOutput, GAMMA_CORRECTION);
	
	//Copied from Lava
	//float sampleHotness = pow(currentLiquidSample, 4.f);
	//float3 emissiveTint = AcidHelper(3000.f * sampleHotness);
	//output += float4(.2f * liquidOutput.a * emissiveTint, liquidOutput.a);

	return output;
}