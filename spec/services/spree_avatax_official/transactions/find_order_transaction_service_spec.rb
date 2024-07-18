require 'spec_helper'

describe SpreeAvataxOfficial::Transactions::FindOrderTransactionService, :avatax_enabled do
  describe '#call' do
    subject                 { described_class.call(order: order) }

    let(:sales_transaction) { create(:spree_avatax_official_transaction, order: order, code: 'test123') }

    context 'with Spree::Order' do
      let(:order) { create(:order, number: 'test123') }

      context 'when order does have a SalesInvoice transaction' do
        it 'returns success' do
          sales_transaction

          expect(subject.success?).to eq true
        end
      end

      context 'when order does NOT have a SalesInvoice transaction', :vcr do
        context 'when transaction exists in avatax' do
          before do
            allow(SpreeAvataxOfficial::Transactions::GetByCodeService).to receive(:call).and_return double(failure?: false)
          end

          it 'returns success and creates a new SalesInvoice transaction' do
            expect(subject.success?).to eq true
            expect(SpreeAvataxOfficial::Transaction.count).to eq 1
          end
        end

        context 'when transaction does NOT exist in avatax' do
          before do
            allow(SpreeAvataxOfficial::Transactions::GetByCodeService).to receive(:call).and_return double(failure?: true)
          end

          it 'returns failure' do
            expect(subject.success?).to eq false
          end
        end
      end
    end
  end
end
