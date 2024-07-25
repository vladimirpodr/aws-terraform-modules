===============================
MODULE: AWS Certificate Manager
===============================

General
=======

This module describes AWS Certificate Manager. 

Module details
==============

Module parameters are:

``tags``
  Tags to assign to the resources.

``hosted_zone_id``
  Id of the zone in the route53.

``domain_name``
  A domain name for which the certificate should be issued.

``subject_alternative_names``
  Set of domains that should be SANs in the issued certificate.

Module outputs are:

``id``
  ID of the secrets.

``arn``
  ARN of the secrets.

.. vim: set ts=2 sw=2 et tw=98 spell: