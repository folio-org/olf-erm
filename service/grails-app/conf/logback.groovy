import grails.util.BuildSettings
import grails.util.Environment
import org.olf.general.jobs.JobAwareAppender
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter

import java.nio.charset.Charset

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter

// See http://logback.qos.ch/manual/groovy.html for details on configuration
appender('STDOUT', ConsoleAppender) {
    encoder(PatternLayoutEncoder) {
        charset = Charset.forName('UTF-8')

        pattern =
                '%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} ' + // Date
                        '%clr(%5p) ' + // Log level
                        '%clr(---){faint} %clr([%15.15t]){faint} ' + // Thread
                        '%clr(%-40.40logger{39}){cyan} %clr(:){faint} ' + // Logger
                        '%m%n%wex' // Message
    }
}

logger ('grails.app.init', DEBUG)
logger ('grails.app.controllers', DEBUG)
logger ('grails.app.domains', DEBUG)
logger ('grails.app.jobs', DEBUG)
logger ('grails.app.services', DEBUG)
logger ('com.k_int', DEBUG)
logger ('pubskb', DEBUG)
logger ('okapi', INFO)
logger ('folio', DEBUG)
logger ('org.olf', DEBUG)
logger ('com.k_int.okapi.OkapiSchemaHandler', WARN)
logger ('com.k_int.web.toolkit.refdata.GrailsDomainRefdataHelpers', WARN)
logger ('com.k_int.web.toolkit.utils.RequestUtils', WARN)
logger ('com.k_int.okapi.remote_resources.RemoteOkapiLinkListener', WARN)

//logger("org.hibernate.SQL", DEBUG)
//logger("org.hibernate.type.descriptor.sql.BasicBinder", TRACE)

// Uncomment below logging for output of OKAPI client http.
logger ('com.k_int.okapi.OkapiClient', DEBUG)

if (Environment.isDevelopmentMode() || Environment.currentEnvironment == Environment.TEST) {
  
  logger ('com.k_int.web.toolkit.refdata.GrailsDomainRefdataHelpers', DEBUG)
  logger ('com.k_int.web.toolkit.utils.RequestUtils', DEBUG)
  logger ('com.k_int.okapi.remote_resources.RemoteOkapiLinkListener', TRACE)
  logger ('com.k_int.okapi.OkapiTenantAdminService', TRACE)
  
  // Uncomment below logging for output of OKAPI client http.
  logger ('com.k_int.okapi.OkapiClient', TRACE)
  logger 'groovy.net.http.JavaHttpBuilder', DEBUG
  logger 'groovy.net.http.JavaHttpBuilder.content', DEBUG
  logger 'groovy.net.http.JavaHttpBuilder.headers', DEBUG
}

def targetDir = BuildSettings.TARGET_DIR
if (Environment.isDevelopmentMode() && targetDir != null) {
    appender("FULL_STACKTRACE", FileAppender) {
        file = "${targetDir}/stacktrace.log"
        append = true
        encoder(PatternLayoutEncoder) {
            pattern = "%level %logger - %msg%n"
        }
    }
    logger("StackTrace", ERROR, ['FULL_STACKTRACE'], false)
}
root(ERROR, ['STDOUT'])

// Add a new appender that logs statements to the database for jobs.
appender ('JOB', JobAwareAppender) 
//{
//  pattern = "%replace(%X{descriminator} - ){' - ', ''}%replace(%X{subDescriminator} - ){' - ', ''}" + // Add the descriminators
//      '%m%n%' // Message
//}

// Add the appender for classes we wish to expose within the database.
logger ('org.olf.PackageIngestService', DEBUG, ['JOB'])
logger ('org.olf.TitleInstanceResolverService', DEBUG, ['JOB'])
logger ('org.olf.TitleEnricherService', DEBUG, ['JOB'])
logger ('org.olf.kb.adapters.GOKbOAIAdapter', DEBUG, ['JOB'])
logger ('org.olf.CoverageService', DEBUG, ['JOB'])
logger ('org.olf.ImportService', DEBUG, ['JOB'])
logger ('org.olf.DocumentAttachmentService', DEBUG, ['JOB'])
