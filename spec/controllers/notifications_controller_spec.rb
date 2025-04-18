describe NotificationsController do
  describe "#create" do
    let!(:user) { create(:user, first_name: "JOHN", last_name: "DOE") }
    let!(:agent) { create(:agent) }
    let!(:organisation) { create(:organisation, agents: [agent]) }
    let!(:motif_category) { create(:motif_category) }
    let!(:rdv) { create(:rdv, organisation: organisation, starts_at: Time.zone.parse("2023-05-20 10:30")) }
    let!(:follow_up) { create(:follow_up, user: user, motif_category: motif_category) }
    let!(:participation) { create(:participation, user: user, rdv: rdv, follow_up: follow_up) }
    let!(:notification) do
      create(:notification,
             participation: participation,
             format: "postal",
             event: "participation_created",
             rdv_solidarites_rdv_id: rdv.rdv_solidarites_rdv_id)
    end

    let!(:create_params) do
      {
        participation_id: participation.id,
        notification: {
          format: "postal",
          event: "participation_created"
        },
        format: "pdf"
      }
    end

    before do
      sign_in(agent)
      allow(Notifications::SaveAndSend).to receive(:call)
        .and_return(OpenStruct.new(success?: true, notification:))
    end

    context "when the service succeeds" do
      context "when generating a PDF notification" do
        before do
          mock_pdf_service(success: true)
        end

        it "is a success" do
          post :create, params: create_params
          expect(response).to be_successful
          expect(response.headers["Content-Type"]).to eq("application/pdf")
        end

        it "renders the notification as a PDF attachment" do
          post :create, params: create_params
          expect(response).to be_successful
          expect(response.headers["Content-Disposition"]).to start_with("attachment; filename=")
          expect(response.headers["Content-Disposition"]).to include(
            "Convocation_de_#{user.first_name}_#{user.last_name}"
          )
        end

        context "when the PDF generation fails" do
          before do
            mock_pdf_service(success: false)
            allow(Sentry).to receive(:capture_message)
          end

          it "informs Sentry of the error" do
            post :create, params: create_params
            expect(Sentry).to have_received(:capture_message).with(
              "PDF generation failed",
              extra: { notification_id: notification.id }
            )
          end
        end
      end
    end

    context "when the service fails" do
      before do
        allow(Notifications::SaveAndSend).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
      end

      it "sets a flash error" do
        request.env["HTTP_REFERER"] = "/previous_path"
        post :create, params: create_params
        expect(flash[:error]).to eq("some error")
      end

      it "redirects back to referer" do
        request.env["HTTP_REFERER"] = "/previous_path"
        post :create, params: create_params
        expect(response).to redirect_to("/previous_path")
      end
    end
  end
end
