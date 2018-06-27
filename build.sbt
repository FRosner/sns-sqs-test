enablePlugins(JavaAppPackaging)

lazy val projectName = "sns-sqs-chat"

lazy val commonSettings = Seq(
  version := "0.1-SNAPSHOT",
  scalaVersion := "2.12.6",
  organization := "de.frosner",
  name := projectName,
  javacOptions ++= Seq("-source", "1.8", "-target", "1.8")
)

lazy val assemblySettings = Seq(
  artifact in (Compile, assembly) := {
    val art = (artifact in (Compile, assembly)).value
    art.withClassifier(Some("assembly"))
  },
  addArtifact(artifact in (Compile, assembly), assembly)
)

lazy val slack = (project in file("slack"))
  .settings(commonSettings: _*)
  .settings(assemblySettings: _*)
  .settings(
    libraryDependencies ++= List(
      "com.amazonaws" % "aws-java-sdk-lambda" % "1.11.344",
      "com.amazonaws" % "aws-lambda-java-core" % "1.2.0",
      "com.softwaremill.sttp" %% "core" % "1.2.1",
      "com.github.pureconfig" %% "pureconfig" % "0.9.1"
    ) ++ List(
      "io.circe" %% "circe-core",
      "io.circe" %% "circe-generic",
      "io.circe" %% "circe-parser").map(_ % "0.9.3")

  )