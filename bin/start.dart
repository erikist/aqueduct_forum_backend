import 'dart:async';
import 'dart:io';

import 'package:aqueduct_forum_backend/aqueduct_forum_backend.dart';

main() async {
  try {
    var configFileName = "config.yaml";
    var logPath = "api.log";

    var config = new AqueductForumBackendConfiguration(configFileName);
    var logger = new LoggingServer([new RotatingLoggingBackend(logPath)]);
    await logger.start();

    var app = new Application<AqueductForumBackendSink>();
    app.configuration.port = config.port;
    app.configuration.configurationOptions = {
      AqueductForumBackendSink.LoggingTargetKey: logger.getNewTarget(),
      AqueductForumBackendSink.ConfigurationKey: config
    };

    await app.start(numberOfInstances: 3);

    var signalPath = new File(".aqueductsignal");
    await signalPath.writeAsString("ok");
  } catch (e, st) {
    await writeError("Server failed to start: $e $st");
  }
}

Future writeError(String error) async {
  var file = new File("error.log");
  await file.writeAsString(error);
}
