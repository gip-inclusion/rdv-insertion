describe FollowUp do
  describe "#action_required" do
    subject { described_class.action_required }

    context "when status requires action" do
      let!(:follow_up) { create(:follow_up, status: "rdv_noshow") }

      it "retrieves the follow_up" do
        expect(subject).to include(follow_up)
      end
    end

    context "when status does not require action nor attention" do
      let!(:follow_up) { create(:follow_up, status: "rdv_seen") }

      it "does not retrieve the follow_up" do
        expect(subject).not_to include(follow_up)
      end
    end
  end

  describe "#set_status" do
    subject { follow_up.set_status }

    context "closed" do
      context "when closed_at is present" do
        let!(:follow_up) { create(:follow_up, closed_at: Time.zone.now) }

        it "is closed" do
          expect(subject).to eq(:closed)
        end
      end
    end

    context "without rdvs" do
      context "without invitations or rdvs" do
        let!(:follow_up) { create(:follow_up, rdvs: [], invitations: []) }

        it "is not invited" do
          expect(subject).to eq(:not_invited)
        end
      end

      context "with no sent invitation" do
        let!(:follow_up) { create(:follow_up, rdvs: []) }

        it "is not invited" do
          expect(subject).to eq(:not_invited)
        end
      end

      context "with invitations" do
        let!(:user) { create(:user) }
        let!(:invitation) { create(:invitation, user: user, created_at: 2.days.ago) }
        let!(:follow_up) { create(:follow_up, user: user, invitations: [invitation]) }

        context "with no participations" do
          it "is in invitation pending" do
            expect(subject).to eq(:invitation_pending)
          end

          context "when the invitation is expired" do
            let!(:invitation) { create(:invitation, user: user, created_at: 5.days.ago, expires_at: 4.days.ago) }

            it "is in invitation expired" do
              expect(subject).to eq(:invitation_expired)
            end
          end
        end

        context "with a seen participation" do
          context "when the invitation has been sent after the created participation" do
            let!(:participation) do
              create(
                :participation,
                created_at: 4.days.ago, user: user, follow_up: follow_up, status: "seen"
              )
            end

            it "is in invitation pending" do
              expect(subject).to eq(:invitation_pending)
            end

            context "when the invitation is expired" do
              before { invitation.update!(expires_at: 4.days.ago) }

              it "is in invitation expired" do
                expect(subject).to eq(:invitation_expired)
              end
            end
          end

          context "when the participation is created after the invitation" do
            let!(:participation) do
              create(
                :participation,
                created_at: 1.day.ago, user: user, follow_up: follow_up, status: "seen"
              )
            end

            it "is the status of the participation" do
              expect(subject).to eq(:rdv_seen)
            end
          end

          context "when the last created participation is seen" do
            let!(:rdv) { create(:rdv, starts_at: 4.days.ago) }
            let!(:participation) do
              create(
                :participation,
                created_at: 1.day.ago, rdv: rdv, user: user, follow_up: follow_up, status: "seen"
              )
            end
            let!(:other_participation) do
              create(:participation, created_at: 2.days.ago, follow_up: follow_up, status: "revoked")
            end

            it "is the status of the participation" do
              expect(subject).to eq(:rdv_seen)
            end
          end

          context "cancelled participation created after the seen participation but before the start of the seen rdv" do
            let!(:rdv) { create(:rdv, starts_at: 1.day.ago) }
            let!(:participation) do
              create(
                :participation,
                created_at: 3.days.ago, rdv: rdv, user: user, follow_up: follow_up, status: "seen"
              )
            end
            let!(:other_participation) do
              create(:participation, created_at: 2.days.ago, follow_up: follow_up, status: "revoked")
            end

            it "is the status of the participation" do
              expect(subject).to eq(:rdv_seen)
            end
          end
        end

        context "when a participation is pending" do
          let!(:rdv) do
            create(:rdv, starts_at: 2.days.from_now)
          end

          let!(:participation) do
            create(
              :participation,
              created_at: 4.days.ago, rdv: rdv, user: user, follow_up: follow_up, status: "unknown"
            )
          end

          it "is pending" do
            expect(subject).to eq(:rdv_pending)
          end
        end

        context "with a cancelled rdv" do
          context "when the invitation has been sent after the participation creation" do
            let!(:rdv) { create(:rdv) }
            let!(:participation) do
              create(
                :participation,
                created_at: 4.days.ago, rdv: rdv, user: user, follow_up: follow_up, status: "noshow"
              )
            end

            it "is in invitation pending" do
              expect(subject).to eq(:invitation_pending)
            end
          end

          context "when the invitation has been sent before the participation creation" do
            let!(:rdv) { create(:rdv) }
            let!(:participation) do
              create(
                :participation,
                created_at: 1.day.ago, rdv: rdv, user: user, follow_up: follow_up, status: "noshow"
              )
            end

            it "is the status of the participation" do
              expect(subject).to eq(:rdv_noshow)
            end
          end
        end

        context "with mutliple participation after invitation" do
          let!(:invitation) { create(:invitation, created_at: 10.days.ago) }
          let!(:rdv) { create(:rdv, starts_at: 2.days.ago) }
          let!(:participation) do
            create(
              :participation,
              created_at: 4.days.ago, rdv: rdv, user: user, follow_up: follow_up, status: "seen"
            )
          end

          let!(:rdv2) { create(:rdv) }
          let!(:participation2) do
            create(
              :participation,
              created_at: 5.days.ago, rdv: rdv2, user: user, follow_up: follow_up, status: "noshow"
            )
          end

          it "is the status of the last created participation" do
            expect(subject).to eq(:rdv_seen)
          end

          context "when a rdv is pending" do
            let!(:rdv3) { create(:rdv) }

            let!(:participation3) do
              create(
                :participation,
                created_at: 8.days.ago, rdv: rdv3, user: user, follow_up: follow_up, status: "unknown"
              )
            end

            it "is rdv_pending" do
              expect(subject).to eq(:rdv_pending)
            end
          end

          context "when the last rdv already took place but the status is not updated" do
            let!(:rdv3) do
              create(:rdv, starts_at: 2.days.ago)
            end

            let!(:participation3) do
              create(
                :participation,
                created_at: 1.day.ago, rdv: rdv3, user: user, follow_up: follow_up, status: "unknown"
              )
            end

            it "is needs status update" do
              expect(subject).to eq(:rdv_needs_status_update)
            end
          end
        end
      end
    end
  end

  describe "#refresh_status_at" do
    subject { follow_up.reload.refresh_status_at }

    let!(:follow_up) { create(:follow_up) }

    context "when there is no invitation or rdv" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when there are invitations and rdvs" do
      let!(:last_rdv_starts_at) { Time.zone.parse("2025-11-24 10:00") }
      let!(:last_invitation_expires_at) { Time.zone.parse("2025-11-22 12:00") }
      let!(:participation) { create(:participation, rdv: create(:rdv, starts_at: last_rdv_starts_at), follow_up:) }
      let!(:old_participation) do
        create(:participation, rdv: create(:rdv, starts_at: last_rdv_starts_at - 7.days), follow_up:)
      end
      let!(:invitation) { create(:invitation, expires_at: last_invitation_expires_at, follow_up:) }

      it "returns the date of the last invitation or rdv" do
        expect(subject).to eq(last_rdv_starts_at + 1.second)
      end
    end

    context "when there are invitations only" do
      let!(:last_invitation_expires_at) { Time.zone.parse("2025-11-22 12:00") }
      let!(:invitation) { create(:invitation, expires_at: last_invitation_expires_at, follow_up:) }

      it "returns the date of the last invitation" do
        expect(subject).to eq(last_invitation_expires_at + 1.second)
      end
    end
  end

  describe "#last_invitation_expires_at" do
    subject { follow_up.reload.last_invitation_expires_at }

    let!(:follow_up) { create(:follow_up) }

    context "when there are invitations" do
      let!(:invitation) { create(:invitation, expires_at: Time.zone.parse("2025-11-22 12:00"), follow_up:) }
      let!(:other_invitation) { create(:invitation, expires_at: Time.zone.parse("2025-11-23 12:00"), follow_up:) }
      let!(:never_expiring_invitation) { create(:invitation, expires_at: nil, follow_up:) }

      it "returns the date of the last invitation" do
        expect(subject).to eq(other_invitation.expires_at)
      end
    end

    context "when there are no invitations" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
