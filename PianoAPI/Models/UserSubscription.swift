import Foundation

@objc(PianoAPIUserSubscription)
public class UserSubscription: NSObject, Codable {

    /// User subscription id
    @objc public var subscriptionId: String? = nil

    
    @objc public var term: Term? = nil

    /// User subscription auto renew
    @objc public var autoRenew: OptionalBool? = nil

    /// Grace period start date
    @objc public var gracePeriodStartDate: Date? = nil

    /// User subscription next bill date
    @objc public var nextBillDate: Date? = nil

    /// The start date.
    @objc public var startDate: Date? = nil

    /// User subscription status
    @objc public var status: String? = nil

    /// Whether this subscription could be cancelled. Cancel means that access no longer be prolongated and current access will be revoked
    @objc public var cancelable: OptionalBool? = nil

    /// Whether this subscription could be cancelled and the payment for the last period could be refunded. Cancel means that access no longer be prolongated and current access will be revoked
    @objc public var cancelableAndRefundadle: OptionalBool? = nil

    /// Term billing plan description
    @objc public var paymentBillingPlanDescription: String? = nil

    public enum CodingKeys: String, CodingKey {
        case subscriptionId = "subscription_id"
        case term = "term"
        case autoRenew = "auto_renew"
        case gracePeriodStartDate = "grace_period_start_date"
        case nextBillDate = "next_bill_date"
        case startDate = "start_date"
        case status = "status"
        case cancelable = "cancelable"
        case cancelableAndRefundadle = "cancelable_and_refundadle"
        case paymentBillingPlanDescription = "payment_billing_plan_description"
    }
}
