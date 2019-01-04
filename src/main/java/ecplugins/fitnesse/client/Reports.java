
// Reports.java --
//
// Reports.java is part of ElectricCommander.
//
// Copyright (c) 2005-2012 Electric Cloud, Inc.
// All rights reserved.
//

package ecplugins.fitnesse.client;

import org.jetbrains.annotations.NonNls;

import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.DecoratorPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import com.electriccloud.commander.client.domain.Property;
import com.electriccloud.commander.client.domain.PropertySheet;
import com.electriccloud.commander.client.requests.GetPropertiesRequest;
import com.electriccloud.commander.client.responses.CommanderError;
import com.electriccloud.commander.client.responses.PropertySheetCallback;
import com.electriccloud.commander.gwt.client.ComponentBase;
import com.electriccloud.commander.gwt.client.protocol.xml.RequestSerializerImpl;
import com.electriccloud.commander.gwt.client.ui.FormTable;
import com.electriccloud.commander.gwt.client.util.CommanderUrlBuilder;

public class Reports
    extends ComponentBase
{

    //~ Methods ----------------------------------------------------------------

    @Override public Widget doInit()
    {

        /* Renders the component. */
        DecoratorPanel rootPanel = new DecoratorPanel();
        VerticalPanel  vPanel    = new VerticalPanel();

        vPanel.setBorderWidth(0);

        String              jobId      = getGetParameter("jobId");
        CommanderUrlBuilder urlBuilder = CommanderUrlBuilder.createUrl(
                                                                "jobDetails.php")
                                                            .setParameter(
                                                                "jobId", jobId);

        // noinspection HardCodedStringLiteral,StringConcatenation
        vPanel.add(new Anchor("Job: " + jobId, urlBuilder.buildString()));

        Widget htmlH1 = new HTML("<h1>FitNesse Results</h1>");

        vPanel.add(htmlH1);

        FormTable formTable = getUIFactory().createFormTable();

        callback("results", formTable);
        vPanel.add(formTable.getWidget());

        FormTable formTableLog = getUIFactory().createFormTable();

        callback("logs", formTableLog);
        vPanel.add(formTableLog.getWidget());
        rootPanel.add(vPanel);

        return rootPanel;
    }

    private void callback(
            @NonNls String  propertyName,
            final FormTable formTable)
    {
        String jobId = getGetParameter("jobId");

        if (getLog().isDebugEnabled()) {
            getLog().debug("this is getGetParameter for jobId: "
                    + getGetParameter("jobId"));
            getLog().debug("this is jobId: " + jobId);
        }

        GetPropertiesRequest req = getRequestFactory()
                .createGetPropertiesRequest();

        // "defectLinks"
        req.setPath("/jobs/" + jobId + "/" + propertyName);

        if (getLog().isDebugEnabled()) {
            getLog().debug(
                "FitNesse Reports doInit: setting up getProperties command request");
        }

        req.setCallback(new PropertySheetCallback() {
                @Override public void handleResponse(PropertySheet response)
                {
                    parseResponse(response, formTable);
                }

                @Override public void handleError(CommanderError error)
                {

                    if (getLog().isDebugEnabled()) {
                        getLog().debug("Error trying to access property");
                    }

                    // noinspection HardCodedStringLiteral
                    formTable.addRow("0", new Label("No Output Found"));
                }
            });

        if (getLog().isDebugEnabled()) {
            getLog().debug("FIT Reports doInit: Issuing Commander request: "
                    + new RequestSerializerImpl().serialize(req));
        }

        doRequest(req);
    }

    /**
     * Helper for handling results properties with a "prop" get param in the
     * prop value.
     *
     * @param  response  jobId
     * @param  form
     */
    private void parseResponse(
            PropertySheet response,
            FormTable     form)
    {

        if (getLog().isDebugEnabled()) {
            getLog().debug("getProperties request returned "
                    + response.getProperties()
                              .size() + " properties");
        }

        for (Property p : response.getProperties()
                                  .values()) {

            if ("fitnesse_report".equals(p.getName())) {
                HTML htmlH1 = new HTML("<h3>FitNesse Log</h3> <pre>"
                            + p.getValue() + "</pre>");

                form.addRow("0", htmlH1);
            }
            else {
                HTML   htmlH1 = new HTML("<h3>XML File</h3>");
                Anchor anchor = new Anchor(p.getName(), p.getValue());

                form.addRow("0", htmlH1);
                form.addRow("1", anchor);
            }

            if (getLog().isDebugEnabled()) {
                getLog().debug("  propertyName="
                        + p.getName()
                        + ", value=" + p.getValue());
            }
        }
    }
}
