package org.olf.kb.adapters;

import org.olf.kb.KBCacheUpdater;
import org.olf.kb.RemoteKB;
import org.olf.kb.KBCache;
import groovy.json.JsonSlurper;

public class KBPlusAdapter implements KBCacheUpdater {


  public Object freshen(String source_id,
                        Object cursor,
                        KBCache cache) {

    // We want this update to happen independently of any other transaction, on it's own, and in the background.
    RemoteKB.withNewTransaction {
      RemoteKB remote_kb_info = RemoteKB.get(source_id)
      def kbplus_cursor_info = null;
      if ( remote_kb_info.cursor != null ) {
        kbplus_cursor_info = new JsonSlurper().parseText(remote_kb_info.cursor)
      }
      else {
        // No cursor - page through everything
      }

      // Package list service uses URLs of the form
      // https://www.kbplus.ac.uk/test2/publicExport/idx?format=json&lastUpdatedAfter=2017-10-14T11:07:00Z&order=lastUpdated&max=10

      remote_kb_info.save(flush:true, failOnError:true);
    }
  }

}