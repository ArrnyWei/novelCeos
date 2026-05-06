import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 訂閱頁底部 FAQ 區。降低使用者疑慮 + 對齊 Apple App Store 政策友善度。
/// ExpansionTile 預設全部收合，使用者主動展開查看。
class SubscriptionFaqSection extends StatelessWidget {
  const SubscriptionFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Theme(
      // 拿掉 ExpansionTile 預設的上下分隔線，視覺更乾淨
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
            child: Text(
              '常見問題',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          ..._faqs.map((q) => _FaqTile(question: q.q, answer: q.a, cs: cs)),
        ],
      ),
    );
  }

  static const List<({String q, String a})> _faqs = [
    (
      q: '什麼時候會扣款？',
      a: '若有免費試用，試用期結束前 24 小時內扣款並開始正式訂閱；若沒有試用，購買當下即扣款。年訂閱會在到期前 24 小時自動續訂。'
    ),
    (
      q: '怎麼取消訂閱？',
      a: '到 iOS「設定 → 你的 Apple ID → 訂閱」即可取消。已扣款的當期仍可使用到期日為止。也可以在這個頁面下方點「管理訂閱」直接跳過去。'
    ),
    (
      q: '終身解鎖跟年訂閱有什麼差別？',
      a: '終身解鎖只買一次、永久去除廣告，不會自動續扣；年訂閱每年扣款，但月平均最便宜。如果你預期會長期使用、推薦終身方案。'
    ),
    (
      q: '支援家庭共享嗎？',
      a: '支援。終身解鎖購買後可透過 iOS 家人共享（最多 6 位家庭成員）一起使用。月/年訂閱依照 Apple 規範同樣可共享。'
    ),
    (
      q: '換手機會繼續嗎？',
      a: '會。同一個 Apple ID 下任何裝置都會自動同步訂閱狀態。換新手機只要登入同個 Apple ID，到訂閱頁點「還原購買記錄」即可。'
    ),
  ];
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final ColorScheme cs;
  const _FaqTile({required this.question, required this.answer, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
        childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
        shape: const Border(),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.6,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
