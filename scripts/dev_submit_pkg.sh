#!/bin/sh


if [ -f ~/folio_privates.sh ]
then
  echo Loading folio_privates script
  . ~/folio_privates.sh
fi

echo Configured::
echo $EBSCO_SANDBOX_CLIENT_ID

# jq -r '.name'

echo Testing for presence of JQ

JQTEST=`echo '{  "value":"one" }' | jq -r ".value" | tr -d '\r'`

if [ $JQREST="one" ]
then
  echo JQ installed and working
else
  echo Please install JQ
  exit 1
fi

echo Running

# Prepolpulate with data.
echo Loading k-int test package
KI_PKG_ID=`curl --header "X-Okapi-Tenant: diku" -X POST -F package_file=@../service/src/integration-test/resources/packages/simple_pkg_1.json http://localhost:8080/erm/admin/loadPackage | jq -r ".newPackageId"  | tr -d '\r'`

echo loading betham science
BSEC_PKG_ID=`curl --header "X-Okapi-Tenant: diku" -X POST -F package_file=@../service/src/integration-test/resources/packages/bentham_science_bentham_science_eduserv_complete_collection_2015_2017_1386.json http://localhost:8080/erm/admin/loadPackage | jq -r ".newPackageId" | tr -d '\r'`

echo Loading APA
APA_PKG_ID=`curl --header "X-Okapi-Tenant: diku" -X POST -F package_file=@../service/src/integration-test/resources/packages/apa_1062.json http://localhost:8080/erm/admin/loadPackage | jq -r ".newPackageId" | tr -d '\r'`

AGREEMENT_TRIAL_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "AgreementType",
  value: "TRIAL",
  label: "Trial"
}
' | jq -r ".id" | tr -d '\r'`

YNO_YES_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "YesNoOther",
  value: "Yes",
  label: "Yes"
}
' | jq -r ".id" | tr -d '\r'`

YNO_NO_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "YesNoOther",
  value: "No",
  label: "No"
}
' | jq -r ".id" | tr -d '\r'`

YNO_OTHER_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "YesNoOther",
  value: "Other",
  label: "Other"
}
' | jq -r ".id" | tr -d '\r'`

STATUS_CURRENT_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "Status",
  value: "Current",
  label: "Current"
}
' | jq -r ".id" | tr -d '\r'`

STATUS_HISTORIC_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "Status",
  value: "Historic",
  label: "Historic"
}
' | jq -r ".id" | tr -d '\r'`

MUST_RENEW_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "RenewalPriority",
  value: "Must",
  label: "Must"
}
' | jq -r ".id" | tr -d '\r'`

NICE_TO_HAVE_RENEW_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "RenewalPriority",
  value: "NiceToHave",
  label: "Nice to Have"
}
' | jq -r ".id" | tr -d '\r'`

AGREEMENT_DRAFT_RDV=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/refdataValues/lookupOrCreate -d '
{
  category: "AgreementType",
  value: "DRAFT",
  label: "Draft"
}
' | jq -r ".id" | tr -d '\r'`

echo Create a trial agreement 

# Create an agreement - Vendor ID generated by uuidgen here, in reality would be fetched from vendor service
TRIAL_AGREEMENT_ID=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/sas -d '
{
  name: "Trial Agreement LR 001",
  description: "This is a trial agreement",
  agreementType: { id: "'"$AGREEMENT_TRIAL_RDV"'" },
  agreementStatus: { id: "'"$STATUS_CURRENT_RDV"'" },
  isPerpetual: { id: "'"$YNO_YES_RDV"'" },
  renewalPriority: { id: "'"$MUST_RENEW_RDV"'" },
  localReference: "TRIAL_ALR_001",
  vendorReference: "TRIAL_AVR_001",
  startDate: "2018-01-01",
  endDate: "2018-12-31",
  renewalDate: "2019-01-01",
  nextReviewDate: "2018-10-01",
  vendor: {
    vendorsUuid: "05f327a6-c4d3-43c2-828f-7d6e7e401c99",
    name:"My Super Vendor",
    sourceURI:"/vendors/some/uri?05f327a6-c4d3-43c2-828f-7d6e7e401c99"
  }
}
' | jq -r ".id" | tr -d '\r'`

echo Create a draft agreement 

# Create an agreement
DRAFT_AGREEMENT_ID=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/sas -d '
{
  name: "Draft Agreement LR 002", 
  description: "This is a draft agreement",
  agreementType: { id: "'"$AGREEMENT_DRAFT_RDV"'" },
  agreementStatus: { id: "'"$STATUS_CURRENT_RDV"'" },
  isPerpetual: { id: "'"$YNO_NO_RDV"'" },
  renewalPriority: { id: "'"$NICE_TO_HAVE_RENEW_RDV"'" },
  localReference: "AGG_LR_002",
  vendorReference: "AGG_VR_002",
  startDate: "2018-01-01"
}
' | jq -r ".id" | tr -d '\r'`

echo Look up package content item ID for CCD in the k-int test package

# Find the package content item entitle for Clinical Cancer Drugs in K-Int Test Package 001
CCD_IN_KI_TEST_PKG=`curl --header "X-Okapi-Tenant: diku" "http://localhost:8080/erm/pci?filters=pti.titleInstance.title%3D%3DClinical+Cancer+Drugs&filters=pkg.name%3D%3DK-Int+Test+Package+001" -X GET | jq -r ".[0].id" | tr -d '\r'`

# List agreements
# AGREEMENT_ID=`curl --header "X-Okapi-Tenant: ${TENANT}" http://localhost:8080/erm/sas -X GET | jq ".[0].id" | tr -d '\r'`
# List packages
# We now get the package back when we load the package above, this is still a cool way to work tho
# PACKAGE_ID=`curl --header "X-Okapi-Tenant: ${TENANT}" http://localhost:8080/erm/packages?stats=true -X GET | jq ".[0].id" | tr -d '\r'`

echo Add the APA package to our trial agreement

curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/sas/$TRIAL_AGREEMENT_ID/addToAgreement -d ' {
  content:[
    { "type":"package", "id": "'"$APA_PKG_ID"'" }
  ]
}
'

echo Add individual title for clincal cancer drugs from package k-int test package to our trial agreement

# Add the title clinical cancer drugs from the package K-Int Test Package 001 to this agreement as a title
curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/sas/$TRIAL_AGREEMENT_ID/addToAgreement -d ' {
  content:[
    { "type":"packageItem", "id": "'"$CCD_IN_KI_TEST_PKG"'" }
  ]
}
'

echo Add a KB record describing KB+

# Register a remote source
RS_KBPLUS_ID=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/kbs -d '
{
  name:"KB+",
  type:"org.olf.kb.adapters.KIJPFAdapter", // K-Int Json Package Format Adapter
  cursor:null,
  uri:"https://www.kbplus.ac.uk/kbplus7/publicExport/idx",
  listPrefix:null,
  fullPrefix:null,
  principal:null,
  credentials:null,
  rectype:"1",
  active:false,
  supportsHarvesting:true
}
'`

echo Add a KB record describing GOKB

# Register a remote source
RS_GOKB_ID=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/kbs -d '
{
  name:"GOKb",
  type:"org.olf.kb.adapters.GOKbOAIAdapter", // K-Int Json Package Format Adapter
  cursor:null,
  uri:"https://gokbt.gbv.de/gokb/oai/index/packages",
  listPrefix:null,
  fullPrefix:"gokb",
  principal:null,
  credentials:null,
  rectype:"1",
  active:true,
  supportsHarvesting:true,
  activationSupported:false,
  activationEnabled:false
}
'`

echo Add a KB record describing EBSCO sandbox API

RS_EBSCO_ID=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/kbs -d '
{
  name:"EBSCO",
  type:"org.olf.kb.adapters.EbscoKBAdapter",
  cursor:null,
  uri:"https://sandbox.ebsco.io",
  listPrefix:null,
  principal:"'"$EBSCO_SANDBOX_CLIENT_ID"'",
  credentials:"'"$EBSCO_SANDBOX_API_KEY"'",
  rectype:"1",
  active:false,
  supportsHarvesting:false,
  activationSupported:false,
  activationEnabled:false
}
'`

RS_GBV_ID=`curl --header "X-Okapi-Tenant: diku" -H "Content-Type: application/json" -X POST http://localhost:8080/erm/kbs -d '
{
  name:"GBV",
  type:"org.olf.kb.adapters.GenericRemoteKBAdapter",
  cursor:null,
  uri:"",
  listPrefix:null,
  principal:"",
  credentials:"",
  rectype:"1",
  active:false,
  supportsHarvesting:false,
  activationSupported:false,
  activationEnabled:false
}
'`

if [ -z "$EBSCO_SANDBOX_CLIENT_ID" ]
then
  echo "No Ebsco API credentials set, skipping pull package"
else
  echo Import EBSCO Bentham Science Package
  EBSCO_BENTHAM_SCI_ID=`curl --header "X-Okapi-Tenant: diku" -X POST "http://localhost:8080/erm/admin/pullPackage?kb=EBSCO&vendorid=301&packageid=3707" | jq -r ".packageId"  | tr -d '\r'`
fi


# If all goes well, you'll get a status message back. After that, try searching your subscribed titles:

curl --header "X-Okapi-Tenant: diku" http://localhost:8080/erm/content -X GET


# Or try the codex interface instead
#curl --header "X-Okapi-Tenant: diku" http://localhost:8080/codex-instances -X GET

# Pull an ID from that record and ask the codex interface for some details
#RECORD_ID="ff80818162a5e9600162a5e9ef63002f"
#curl --header "X-Okapi-Tenant: diku" http://localhost:8080/codex-instances/$RECORD_ID -X GET
