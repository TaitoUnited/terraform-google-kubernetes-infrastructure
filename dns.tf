/**
 * Copyright 2020 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_dns_managed_zone" "dns_zone" {
  depends_on    = [google_project_service.compute]
  count         = length(local.dnsZones)

  name          = local.dnsZones[count.index].name
  dns_name      = local.dnsZones[count.index].dnsName
  visibility    = local.dnsZones[count.index].visibility

  dnssec_config {
    state       = try(local.dnsZones[count.index].dnssec.state, "off")
  }
}

resource "google_dns_record_set" "dns_record_set" {
  depends_on    = [google_dns_managed_zone.dns_zone]
  count         = length(local.dnsZoneRecordSets)

  name = local.dnsZoneRecordSets[count.index].dnsName
  type = local.dnsZoneRecordSets[count.index].type
  ttl  = local.dnsZoneRecordSets[count.index].ttl

  managed_zone  = local.dnsZoneRecordSets[count.index].dnsZone.name

  rrdatas       = local.dnsZoneRecordSets[count.index].values
}
