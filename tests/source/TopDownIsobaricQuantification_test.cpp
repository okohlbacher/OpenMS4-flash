// Copyright (c) 2002-present, OpenMS Inc. -- EKU Tuebingen, ETH Zurich, and FU Berlin
// SPDX-License-Identifier: BSD-3-Clause
//
// --------------------------------------------------------------------------
// $Maintainer: Kyowon Jeong $
// $Authors: OpenMS contributors $
// --------------------------------------------------------------------------

#include <OpenMS/ANALYSIS/TOPDOWN/TopDownIsobaricQuantification.h>
#include <OpenMS/CONCEPT/ClassTest.h>
#include <OpenMS/KERNEL/MSExperiment.h>

using namespace OpenMS;

START_TEST(TopDownIsobaricQuantification, "$Id$")

START_SECTION(Precursor differences below one Dalton retain the configured tolerance)
{
  MSExperiment experiment;
  MSSpectrum survey;
  survey.setMSLevel(1);
  survey.setRT(1.0);
  survey.emplace_back(500.0, 1000.0f);
  survey.emplace_back(500.25, 1000.0f);
  experiment.addSpectrum(survey);

  std::vector<DeconvolvedSpectrum> deconvolved;
  for (int index = 0; index < 2; ++index)
  {
    MSSpectrum spectrum;
    spectrum.setMSLevel(2);
    spectrum.setRT(2.0 + index);
    spectrum.emplace_back(114.1112, index == 0 ? 100.0f : 300.0f);
    Precursor precursor;
    precursor.setMZ(500.0 + index * 0.25);
    precursor.setCharge(2);
    precursor.setIntensity(1000.0f);
    precursor.setActivationMethods({Precursor::ActivationMethod::HCD});
    spectrum.getPrecursors().push_back(precursor);
    experiment.addSpectrum(spectrum);
    deconvolved.emplace_back(index + 2);
    deconvolved.back().setOriginalSpectrum(spectrum);
  }

  TopDownIsobaricQuantification quantifier;
  Param parameters = quantifier.getParameters();
  parameters.setValue("type", "itraq4plex");
  parameters.setValue("isotope_correction", "false");
  quantifier.setParameters(parameters);
  quantifier.quantify(experiment, deconvolved, {});

  const auto first = deconvolved[0].getQuantities();
  const auto second = deconvolved[1].getQuantities();
  TEST_EQUAL(first.quantities.size(), 4)
  TEST_EQUAL(second.quantities.size(), 4)
  ABORT_IF(first.quantities.size() != 4 || second.quantities.size() != 4)
  TEST_REAL_SIMILAR(first.quantities[0], 100.0)
  TEST_REAL_SIMILAR(second.quantities[0], 300.0)
}
END_SECTION

END_TEST
