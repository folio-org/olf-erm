package org.olf

import static groovyx.net.http.ContentTypes.*
import static groovyx.net.http.HttpBuilder.configure
import static org.springframework.http.HttpStatus.*

import org.olf.kb.PackageContentItem
import org.olf.kb.Pkg
import org.olf.kb.PlatformTitleInstance

import com.k_int.okapi.OkapiHeaders
import com.k_int.okapi.OkapiTenantResolver
import geb.spock.GebSpec
import grails.gorm.multitenancy.Tenants
import grails.testing.mixin.integration.Integration
import groovy.json.JsonSlurper
import groovyx.net.http.ChainedHttpConfig
import groovyx.net.http.FromServer
import groovyx.net.http.HttpBuilder
import groovyx.net.http.HttpVerb
import java.time.LocalDate
import spock.lang.Stepwise
import spock.lang.Unroll
import groovy.util.logging.Slf4j
import java.text.SimpleDateFormat 

@Slf4j
@Integration
@Stepwise
class EntitlementLogSpec extends BaseSpec {

  def importService

  private substitute(Map m) {
    m.each { k, v ->
      if ( v instanceof Map ) {
        substitute(v);
      }
      else if ( v instanceof List ) {
        v.each { lv ->
          if ( lv instanceof Map ) {
            substitute(lv)
          }
        }
      }
      else if ( v instanceof String ) {
        if ( v.startsWith('__EXPR:') ) {
          log.debug("Process expression ${v}");

          // Here we will eval the expression, but for now just test the tree walking
          m[k] = '2021-01-01'
        }
      }
    }
  }

  void "Load Packages" (test_package_file) {

    when: 'File loaded'

      def jsonSlurper = new JsonSlurper()
      def package_data = jsonSlurper.parse(new File(test_package_file))

      SimpleDateFormat sdf = new java.text.SimpleDateFormat ('yyyy-MM-dd')
      String today = sdf.format(new Date());

      substitute(package_data);

      int result = 0
      final String tenantid = currentTenant.toLowerCase()
      Tenants.withId(OkapiTenantResolver.getTenantSchemaName( tenantid )) {
        result = importService.importPackageUsingInternalSchema( package_data )
      }

    then: 'Package imported'
      result > 0

    where:
      test_package_file | _
      'src/integration-test/resources/packages/entitlement_log_package_a.json' | _
  }
  
  void "List Current Agreements"() {

    when:"We ask the system to list known Agreements"
      List resp = doGet("/erm/sas")

    then: "The system responds with a list of 0"
      resp.size() == 0
  }

  void "Check that we don't currently have any subscribed content" () {

    when:"We ask the subscribed content controller to list the titles we can access"
    
      List resp = doGet("/erm/titles/entitled")

    then: "The system responds with an empty list"
      resp.size() == 0
  }

}

