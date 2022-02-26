/**
 * Copyright 2018 Google LLC
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

module "gke" {
  source = "../modules/safer-cluster"
  project_id              = module.enabled_google_apis.project_id
  name                    = var.cluster_name
  regional                = true
  region                  = var.region
  #zones                   = ["us-central1-a"]
  network                 = var.network
  subnetwork              = var.subnetwork
  ip_range_pods           = var.ip_range_pods
  ip_range_services       = var.ip_range_services
  create_service_account  = false
  service_account         = var.compute_engine_service_account
  grant_registry_access   = true
  enable_private_endpoint = true
  enable_private_nodes    = true
  master_ipv4_cidr_block  = "172.18.1.128/28"
  #default_max_pods_per_node = 25
  remove_default_node_pool  = true
  release_channel           = "REGULAR"
  maintenance_start_time    = "2021-12-11T05:00:00Z"
  maintenance_end_time      = "2021-12-12T05:00:00Z"
  maintenance_recurrence    = "FREQ=WEEKLY;BYDAY=SA,SU"
  #Dataplane V2 enable
  datapath_provider         = "DATAPATH_PROVIDER_UNSPECIFIED"
  enable_intranode_visibility = true
  #Control plane global access
  master_global_access_enabled = true
  #Google Groups for RBAC (# informationsecurityall-cc@west.com)
  #authenticator_security_group = "gke-security-groups@west.com"
  node_pools = [
    {
      name              = "${var.project_id}-pool-01"
      #node_locations    = "us-central1-a"
      min_count         = 2
      #max_count         = 10
      local_ssd_count   = 0
      disk_size_gb      = 40
      disk_type         = "pd-standard"
      image_type        = "COS_CONTAINERD"
      auto_repair       = true
      auto_upgrade      = true
      //service_account   = var.compute_engine_service_account
      preemptible       = false
      max_pods_per_node = 64
      pod_range         = "${var.ip_range_pods}"
      enable_secure_boot =true
      machine_type      ="n1-standard-4"
    },
  ]

  #either use west VPN cidr range
  master_authorized_networks = [
    {
      cidr_block   = "10.59.37.0/24"
      display_name = "Worker Pool"
    },
    {
      cidr_block   = "10.113.80.72/32"
      display_name = "VM Instance-devtest-01"
    },
  ]

  istio             = var.istio
  cloudrun          = var.cloudrun
  dns_cache         = var.dns_cache
  gce_pd_csi_driver = var.gce_pd_csi_driver
}
