import SwiftUI
import WebKit

struct NgoEventDetailsView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    @State private var showInfoPack = false
    @State private var showDeleteAlert = false
    @StateObject private var eventViewModel = EventCardViewModel.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let photoURL = event.eventPhotoURL,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(15)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                    }
                }
                basicInfoSection
                
                dateSection
                
                participantSection
                
                countriesSection
                
                includedItemsSection
                
                if let infoPackURL = event.eventInfoPackURL {
                    infoPackButton(url: infoPackURL)
                }
                
                deleteButton
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInfoPack) {
            if let url = URL(string: event.eventInfoPackURL ?? "") {
                SafariWebView(url: url)
            }
        }
        .alert("Delete Event", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.title)
                .font(.title)
                .fontWeight(.bold)
            
            DetailRow(icon: "mappin.circle.fill", title: "Country", value: event.country)
            DetailRow(icon: "tag.fill", title: "Type", value: event.type)
            DetailRow(icon: "book.fill", title: "Topic", value: event.topic)
            if !event.otherTopic.isEmpty {
                DetailRow(icon: "text.bubble.fill", title: "Other Topic", value: event.otherTopic)
            }
            DetailRow(icon: "eurosign.circle.fill", title: "Reimbursement", value: "\(Int(event.reimbursementLimit))€")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Event Dates")
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start Date")
                        .foregroundColor(.secondary)
                    Text(formatDate(event.startDate))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("End Date")
                        .foregroundColor(.secondary)
                    Text(formatDate(event.endDate))
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var participantSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Looking For")
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(event.lookingFor.enumerated()), id: \.offset) { _, participant in
                    HStack {
                        Text("\(CountryList.flag(for: participant.nationality)) \(participant.nationality)")
                        Spacer()
                        Text("\(participant.count) participants")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var countriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Participating Organizations")
            
            ForEach(event.countries, id: \.country) { country in
                HStack {
                    Text(CountryList.flag(for: country.country))
                    Text(country.country)
                    Spacer()
                    Text(country.ngoName)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var includedItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Included Items")
            
            HStack(spacing: 20) {
                if event.includedItems.accommodation {
                    IncludedItemBadge(icon: "bed.double.fill", text: "")
                }
                if event.includedItems.transportation {
                    IncludedItemBadge(icon: "airplane", text: "")
                }
                if event.includedItems.food {
                    IncludedItemBadge(icon: "fork.knife", text: "")
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private func infoPackButton(url: String) -> some View {
        Button(action: {
            showInfoPack = true
        }) {
            HStack {
                Image(systemName: "doc.fill")
                Text("View Info Pack")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue)
            )
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Event")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.red)
            )
        }
    }
    
    private func deleteEvent() {
        guard let eventId = event.id else { return }
        
        Task {
            do {
                try await eventViewModel.deleteEvent(eventId: eventId)
                dismiss()
            } catch {
                print("Error deleting event: \(error.localizedDescription)")
            }
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

