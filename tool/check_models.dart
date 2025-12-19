import 'package:google_generative_ai/google_generative_ai.dart';

const String kGeminiApiKey = 'AIzaSyBYVxtZSpEOn-WFPY9ODIeSZvgSxTL-lj4';

void main() async {
  // Use a generic model placeholder just to initialize if needed, 
  // but list_models is a static or client method?
  // Actually, the SDK doesn't expose listModels securely/easily in the top level.
  // Wait, looking at the docs for `google_generative_ai`... 
  // It effectively wraps the REST API. 
  // There isn't a direct "GenerativeModel.listModels" method in the Dart SDK 0.4.x easily accessible 
  // without digging or using a specific client.
  
  // BUT, let's try to just hit the REST endpoint with curl if the SDK is opaque, 
  // OR look for the method. The error message suggests "Call ListModels".
  
  // Since I might not be able to easily browse the SDK source here, 
  // I will use `curl` in the terminal to list models. It's more reliable for debugging the KEY itself.
}
