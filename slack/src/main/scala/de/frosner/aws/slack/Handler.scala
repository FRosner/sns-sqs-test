package de.frosner.aws.slack

import java.io.{InputStream, OutputStream, PrintStream}
import io.circe.parser.decode
import io.circe.generic.auto._
import io.circe.syntax._
import com.softwaremill.sttp._

import com.amazonaws.services.lambda.runtime.{
  Context,
  RequestHandler,
  RequestStreamHandler
}

import scala.io.Source

class Handler extends RequestStreamHandler {
  override def handleRequest(input: InputStream,
                             output: OutputStream,
                             context: Context): Unit = {
    val logger = context.getLogger
    val hookUrl = System.getenv("hook_url")
    require(hookUrl != null, "$hook_url must be set")
    logger.log("Processing request")
    val inputJsonString = Source.fromInputStream(input).mkString
    logger.log(s"Received the following input: $inputJsonString")
    val notification = decode[Notification](inputJsonString)
    val out = new PrintStream(output)
    val processingResult = for {
      notification <- decode[Notification](inputJsonString)
      message <- decode[Message](notification.Message)
    } yield {
      logger.log(s"Decoded notification: $notification")
      logger.log(s"Decoded message: $message")
      implicit val backend = HttpURLConnectionBackend()
      sttp
        .post(Uri(java.net.URI.create(hookUrl)))
        .contentType("application/json")
        .body(
          SlackMessage(Handler.notificationText(notification, message)).asJson.noSpaces)
        .send()
    }
    processingResult match {
      case Right(response) => out.print(s"Response from hook: ${response.code}")
      case Left(error)     => out.print(s"Failed: $error")
    }
    out.close()
  }

}

object Handler {
  def notificationText(notification: Notification, message: Message): String = {
    val body = message.Records.headOption
      .map { r =>
        s"Someone uploaded ${r.s3.`object`.key} to ${r.s3.bucket.name}."
      }
      .getOrElse("No message received.")
    s"${notification.Subject}: $body"
  }
}
